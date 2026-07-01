import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/feat/user/profile/state/profile_state.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_request_model.dart';
import 'package:template_a/feat/user/profile/domain/usecases/delete_account_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_city_languages_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_profile_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/update_language_usecase.dart';
import 'package:template_a/feat/auth/services/auth_service.dart';
import 'package:template_a/feat/user/profile/domain/usecases/update_profile_usecase.dart' show UpdateProfileUseCase, UpdateProfileParams, updateProfileUseCaseProvider;
import 'package:permission_handler/permission_handler.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_language_preference_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_notification_prefs_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/save_notification_prefs_usecase.dart';

final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, ProfileState>(
  () => ProfileController(),
);

class ProfileController extends Notifier<ProfileState> {
  late GetProfileUseCase _getProfileUseCase;
  late UpdateProfileUseCase _updateProfileUseCase;
  late DeleteAccountUseCase _deleteAccountUseCase;
  late UpdateLanguageUseCase _updateLanguageUseCase;
  late GetCityLanguagesUseCase _getCityLanguagesUseCase;
  late GetLanguagePreferenceUseCase _getLanguagePreferenceUseCase;
  late GetNotificationPrefsUseCase _getNotificationPrefsUseCase;
  late SaveNotificationPrefsUseCase _saveNotificationPrefsUseCase;

  @override
  ProfileState build() {
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    _updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    _deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
    _updateLanguageUseCase = ref.read(updateLanguageUseCaseProvider);
    _getCityLanguagesUseCase = ref.read(getCityLanguagesUseCaseProvider);
    _getLanguagePreferenceUseCase = ref.read(getLanguagePreferenceUseCaseProvider);
    _getNotificationPrefsUseCase = ref.read(getNotificationPrefsUseCaseProvider);
    _saveNotificationPrefsUseCase = ref.read(saveNotificationPrefsUseCaseProvider);
    return const ProfileState();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(status: StateEnum.loading, clearMessage: true);
    final result = await _getProfileUseCase.call(const NoParams());
    result.fold(
      (error) {
        dev.log('[ProfileController] Load error: $error');
        state = state.copyWith(
          status: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (response) {
        final data = response.data;
        state = state.copyWith(
          status: StateEnum.initial,
          userId: data?.id,
          firstName: data?.firstName ?? '',
          lastName: data?.lastName ?? '',
          email: data?.email,
          profilePhotoUrl: data?.profilePhotoUrl,
          salutationCode: data?.salutationCode,
        );
      },
    );
  }

  Future<void> updateProfile() async {
    final userId = state.userId;
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        status: StateEnum.errorSnackBar,
        message: 'User ID not found. Please re-login.',
      );
      return;
    }

    state = state.copyWith(status: StateEnum.loadingDialog, clearMessage: true);

    final request = PostProfileDataRequestModel(
      firstName: state.firstName,
      lastName: state.lastName,
      salutationCode: state.salutationCode,
    );

    final result = await _updateProfileUseCase.call(
      UpdateProfileParams(request: request, userId: userId),
    );
    result.fold(
      (error) {
        dev.log('[ProfileController] Update error: $error');
        state = state.copyWith(
          status: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (_) => state = state.copyWith(
        status: StateEnum.success,
        message: 'profile_update_success',
      ),
    );
  }

  Future<bool> deleteAccount() async {
    if (state.userId == null || state.userId!.isEmpty) {
      state = state.copyWith(status: StateEnum.loading, clearMessage: true);
      await loadProfileData();
      if (state.userId == null || state.userId!.isEmpty) {
        state = state.copyWith(
          status: StateEnum.errorSnackBar,
          message: 'User not found. Please re-login.',
        );
        return false;
      }
    }

    state = state.copyWith(status: StateEnum.loadingDialog, clearMessage: true);
    final result = await _deleteAccountUseCase.call(userId: state.userId);

    bool deleted = false;
    Exception? deleteError;
    result.fold((e) => deleteError = e, (_) => deleted = true);

    try {
      if (deleted) {
        await _clearAuthState();
      } else if (deleteError != null) {
        dev.log('[ProfileController] Delete error: $deleteError');
        state = state.copyWith(
          status: StateEnum.errorSnackBar,
          message: deleteError.toString(),
        );
      }
    } catch (e) {
      dev.log('[ProfileController] Provider disposed during delete cleanup: $e');
    }
    return deleted;
  }

  Future<void> loadCityLanguages() async {
    state = state.copyWith(isLoadingLanguages: true);
    final result = await _getCityLanguagesUseCase.call(const NoParams());
    result.fold(
      (error) {
        dev.log('[ProfileController] City languages error: $error');
        state = state.copyWith(
          isLoadingLanguages: false,
          status: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isLoadingLanguages: false,
          enabledLanguages: response.data?.enabledLanguages ?? [],
          defaultLanguage: response.data?.defaultLanguage,
        );
      },
    );
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(status: StateEnum.loading, clearMessage: true);
    final result = await _updateLanguageUseCase.call(
      UpdateLanguageParams(language),
    );
    result.fold(
      (error) => state = state.copyWith(
        status: StateEnum.errorSnackBar,
        message: error.toString(),
      ),
      (_) => state = state.copyWith(status: StateEnum.initial),
    );
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  Future<void> loadLanguagePreference() async {
    final result = await _getLanguagePreferenceUseCase.call(const NoParams());
    result.fold(
      (error) => dev.log('[ProfileController] Language preference error: $error'),
      (response) {
        final lang = response.data?.preferredLanguage;
        if (lang != null && lang.isNotEmpty) {
          state = state.copyWith(preferredLanguage: lang);
        }
      },
    );
  }

  Future<bool> _getDeviceNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  Future<void> loadNotificationPrefs() async {
    state = state.copyWith(isLoadingNotificationPrefs: true);

    final deviceGranted = await _getDeviceNotificationGranted();

    final result = await _getNotificationPrefsUseCase.call(const NoParams());
    result.fold(
      (error) {
        dev.log('[ProfileController] Notification prefs error: $error');
        state = state.copyWith(
          isLoadingNotificationPrefs: false,
          deviceNotificationGranted: deviceGranted,
          status: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (response) {
        final prefs = ref.read(preferenceManagerProvider);
        prefs.saveBool(StorageKeys.notificationsEnabled, response.data?.notificationsEnabled ?? false);
        prefs.saveBool(StorageKeys.newsletterEnabled, response.data?.newsletterSubscribed ?? false);
        state = state.copyWith(
          isLoadingNotificationPrefs: false,
          deviceNotificationGranted: deviceGranted,
          notificationsEnabled: response.data?.notificationsEnabled ?? false,
          newsletterSubscribed: response.data?.newsletterSubscribed ?? false,
        );
      },
    );
  }

  Future<void> recheckDeviceNotificationPermission() async {
    final nowGranted = await _getDeviceNotificationGranted();

    final permissionJustGranted = !state.deviceNotificationGranted && nowGranted;
    state = state.copyWith(
      deviceNotificationGranted: nowGranted,
      notificationsEnabled: permissionJustGranted ? true : state.notificationsEnabled,
    );

    if (permissionJustGranted) {
      await saveNotificationPrefs();
    }
  }

  Future<void> saveNotificationPrefs({
    bool? notificationsOverride,
    bool? newsletterOverride,
    String? successMessage,
  }) async {
    final previousNotificationsEnabled = state.notificationsEnabled;
    final previousNewsletterSubscribed = state.newsletterSubscribed;

    final targetNotifications = notificationsOverride ?? state.notificationsEnabled;
    final targetNewsletter = newsletterOverride ?? state.newsletterSubscribed;

    state = state.copyWith(
      status: StateEnum.loadingDialog,
      clearMessage: true,
      notificationsEnabled: targetNotifications,
      newsletterSubscribed: targetNewsletter,
    );

    final result = await _saveNotificationPrefsUseCase.call(
      SaveNotificationPrefsParams(
        notificationsEnabled: targetNotifications,
        newsletterSubscribed: targetNewsletter,
      ),
    );
    result.fold(
      (error) {
        dev.log('[ProfileController] Save notification prefs error: $error');
        state = state.copyWith(
          status: StateEnum.errorSnackBar,
          message: error.toString(),
          notificationsEnabled: previousNotificationsEnabled,
          newsletterSubscribed: previousNewsletterSubscribed,
        );
      },
      (_) {
        final prefs = ref.read(preferenceManagerProvider);
        prefs.saveBool(StorageKeys.notificationsEnabled, state.notificationsEnabled);
        prefs.saveBool(StorageKeys.newsletterEnabled, state.newsletterSubscribed);
        state = state.copyWith(
          status: StateEnum.success,
          message: successMessage,
        );
      },
    );
  }

  Future<void> refreshDevicePermissionStatus() async {
    state = state.copyWith(
      deviceNotificationGranted: await _getDeviceNotificationGranted(),
    );
  }

  void resetMessageState() {
    state = state.copyWith(status: StateEnum.initial, clearMessage: true);
  }

  Future<void> _clearAuthState() async {
    await ref.read(authServiceProvider).clearTokens();
    final prefs = ref.read(preferenceManagerProvider);
    prefs.saveBool(StorageKeys.authIsLoggedIn, false);
    prefs.saveBool(StorageKeys.authIsGuest, false);
    ref.read(authStateProvider.notifier).setLoggedOut();
  }
}