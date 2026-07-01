import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/src/image_upload/domain/usecase/profile_image_upload_usecase.dart';
import 'package:common_components/src/image_upload/domain/usecase/profile_image_delete_usecase.dart';
import 'package:common_components/src/image_upload/model/request/image_upload_request_model.dart';
import 'package:common_components/src/image_upload/model/request/image_delete_request_model.dart';
import 'package:template_b/feat/profile/data/models/edit_profile_request_model.dart';
import 'package:template_b/feat/profile/domain/usecases/update_profile_usecase.dart';
import 'package:template_b/feat/profile/state/edit_profile_state.dart';

import 'profile_controller.dart';

/// Provider for edit profile controller
final editProfileControllerProvider =
    NotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>(
      () => EditProfileNotifier(),
    );

/// Notifier managing edit profile logic
class EditProfileNotifier extends Notifier<EditProfileState> {
  late UpdateProfileUseCase _updateProfileUseCase;
  late ProfileImageUploadUsecase _imageUploadUsecase;
  late ProfileImageDeleteUsecase _imageDeleteUsecase;

  @override
  EditProfileState build() {
    _updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    _imageUploadUsecase = ref.read(profileImageUploadUsecaseProvider);
    _imageDeleteUsecase = ref.read(profileImageDeleteUsecaseProvider);
    return EditProfileState();
  }

  void updateFile(File? file) {
    state = state.copyWith(file: file, pendingDelete: false);
  }

  void deleteAvatar() {
    state = state.copyWith(pendingDelete: true, clearFile: true);
  }

  Future<bool> _uploadStagedImage(File file) async {
    state = state.copyWith(isUploadingImage: true, error: null);

    final result = await _imageUploadUsecase.call(
      ImageUploadRequestModel(
        filePath: file.path,
        entityType: 'user',
        mediaType: 'avatar',
      ),
    );

    bool success = false;
    result.fold(
      (error) {
        state = state.copyWith(isUploadingImage: false, error: error.toString());
      },
      (response) {
        state = state.copyWith(isUploadingImage: false);
        final newAvatarUrl = response.data?.url;
        if (newAvatarUrl != null) {
          final currentProfile = ref.read(profileControllerProvider).data;
          if (currentProfile != null) {
            ref.read(profileControllerProvider.notifier).setProfileData(
                  currentProfile.copyWith(avatarUrl: newAvatarUrl),
                );
          }
        }
        success = true;
      },
    );

    return success;
  }

  /// Deletes the current avatar. Returns false and sets error on failure.
  Future<bool> _deletePendingAvatar() async {
    final currentAvatarUrl = ref.read(profileControllerProvider).data?.avatarUrl;

    if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) return true;

    final result = await _imageDeleteUsecase.call(
      ImageDeleteRequestModel(
        mediaUrl: currentAvatarUrl,
        entityType: 'user',
      ),
    );

    bool success = false;
    result.fold(
      (error) {
        state = state.copyWith(error: error.toString());
      },
      (_) {
        final currentProfile = ref.read(profileControllerProvider).data;
        if (currentProfile != null) {
          ref.read(profileControllerProvider.notifier).setProfileData(
                currentProfile.copyWith(avatarUrl: ''),
              );
        }
        success = true;
      },
    );

    return success;
  }

  Future<void> submitForm({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String website,
    required String information,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final userId = ref.read(profileControllerProvider).data?.id;

    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'User ID not found. Please re-login.',
      );
      return;
    }

    final result = await _updateProfileUseCase.call(
      UpdateProfileParams(
        request: EditProfileRequestModel(
          username: username,
          firstName: firstName,
          lastName: lastName,
          email: email,
          website: website,
          information: information,
        ),
        userId: userId,
      ),
    );

    bool formSuccess = false;
    String? successMessage;

    result.fold(
      (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
      (profile) {
        formSuccess = true;
        successMessage = profile.message;
        ref.read(profileControllerProvider.notifier).setProfileData(profile);
      },
    );

    if (!formSuccess) return;

    final stagedFile = state.file;

    if (stagedFile != null) {
      final uploaded = await _uploadStagedImage(stagedFile);
      if (!uploaded) {
        state = state.copyWith(isLoading: false);
        return;
      }
    } else if (state.pendingDelete) {
      final deleted = await _deletePendingAvatar();
      if (!deleted) {
        state = state.copyWith(isLoading: false);
        return;
      }
    }

    state = state.copyWith(
      isLoading: false,
      isSuccess: true,
      successMessage: successMessage,
    );
  }
}
