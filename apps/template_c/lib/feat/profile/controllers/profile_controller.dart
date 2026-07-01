import 'dart:developer' as developer;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/feature_flags.dart';
import 'package:template_c/feat/auth/domain/usecases/logout_usecase.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';
import 'package:template_c/feat/profile/domain/usecases/get_profile_usecase.dart';
import 'package:template_c/feat/profile/state/profile_state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constant/storage_keys.dart';

final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, ProfileState>(
      () => ProfileController(),
    );

class ProfileController extends Notifier<ProfileState> {
  late LogoutUseCase _logoutUseCase;
  late AppPreferenceManager _preferences;
  late GetProfileUseCase _getProfileUseCase;

  @override
  ProfileState build() {
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _preferences = ref.read(preferenceManagerProvider);
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);

    Future.microtask(() {
      getProfile();
      loadUserType();
      loadNotificationStatus();
    });
    return const ProfileState();
  }

  void loadUserType() async {
    final userType = _preferences.getStringOrEmpty(StorageKeys.authRole);
    final isGuestUser = userType.isNotEmpty && userType == UserRole.guest.value;
    state = state.copyWith(isGuestUser: isGuestUser);
  }

  Future<void> loadNotificationStatus() async {
    state = state.copyWith(notificationsEnabled: false);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> logout() async {
    state = state.copyWith(state: StateEnum.loading);
    await _logoutUseCase.call(NoParams());
    state = state.copyWith(state: StateEnum.unauthorize);
  }

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
    final existing = state.data;
    final merged = (existing != null)
        ? profile.copyWith(
            events: profile.events ?? existing.events,
            organizer: profile.organizer ?? existing.organizer,
          )
        : profile;
    state = state.copyWith(state: StateEnum.success, data: merged);
  }

  void getVersionName() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      state = state.copyWith(version: packageInfo.version);
    } catch (error) {
      debugPrint('error while getting version name: $error');
    }
  }
}
