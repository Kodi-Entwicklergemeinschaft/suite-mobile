import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:flutter/material.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/profile/state/profile_state.dart';
import 'package:template_b/feat/profile/domain/usecases/get_profile_usecase.dart';
import 'package:template_b/feat/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_b/feat/profile/data/models/profile_model.dart';
import 'package:template_b/feat/auth/domain/usecases/logout_usecase.dart';
import 'package:template_b/feat/auth/domain/usecases/guest_auth_usecase.dart';
import 'package:template_b/feat/auth/data/models/request_model/guest_auth_request_model.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';

/// Provider for profile controller
final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
      () => ProfileNotifier(),
    );

/// Notifier managing profile logic
class ProfileNotifier extends Notifier<ProfileState> {
  late GetProfileUseCase _getProfileUseCase;
  late LogoutUseCase _logoutUseCase;

  @override
  ProfileState build() {
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    Future.microtask(() {
      getProfile();
    });
    return ProfileState();
  }

  /// Fetch current user profile
  Future<void> getProfile() async {
    state = state.copyWith(state: StateEnum.loading);

    final result = await _getProfileUseCase.call(NoParams());
    result.fold(
      (error) {
        developer.log(
          'Get Profile Error: $error',
          name: 'ProfileController.getProfile',
          error: error,
        );
        state = state.copyWith(
          state: StateEnum.error,
          message: error.toString(),
        );
      },
      (profile) {
        developer.log(
          'Get Profile Success',
          name: 'ProfileController.getProfile',
        );
        state = state.copyWith(state: StateEnum.success, data: profile);
      },
    );
  }

  void setProfileData(ProfileModel profile) {
    state = state.copyWith(state: StateEnum.success, data: profile);
  }

  /// Refresh profile data
  void refreshProfile() => getProfile();

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    developer.log('Logout Request', name: 'ProfileController.logout');

    final result = await _logoutUseCase.call(const NoParams());

    // Always clear local auth state regardless of API result
    ref.read(authStateProvider.notifier).setLoggedOut();
    state = state.copyWith(state: StateEnum.success);
    _reAuthenticateAsGuest();

    result.fold(
      (error) => developer.log(
        'Logout API error (ignored, tokens cleared locally): $error',
        name: 'ProfileController.logout',
        error: error,
      ),
      (_) => developer.log('Logout Success', name: 'ProfileController.logout'),
    );
  }

  Future<void> _reAuthenticateAsGuest() async {
    try {
      final prefs = ref.read(preferenceManagerProvider);
      final deviceId = prefs.getStringOrNull(StorageKeys.deviceId);
      if (deviceId == null || deviceId.isEmpty) return;
      await ref
          .read(guestAuthUseCaseProvider)
          .call(GuestAuthRequestModel(deviceId: deviceId));
      developer.log(
        'Guest re-auth after logout successful',
        name: 'ProfileController._reAuthenticateAsGuest',
      );
      await ref.read(bottomNavigationProvider.notifier).loadConfig();
    } catch (e) {
      developer.log(
        'Guest re-auth after logout failed: $e',
        name: 'ProfileController._reAuthenticateAsGuest',
      );
    }
  }
}
