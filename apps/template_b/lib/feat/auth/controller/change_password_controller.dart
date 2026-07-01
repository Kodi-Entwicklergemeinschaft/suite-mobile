import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/secure_preferences.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/auth/domain/usecases/logout_usecase.dart';
import 'package:template_b/feat/auth/state/change_password_state.dart';
import 'package:template_b/feat/auth/domain/usecases/change_password_usecase.dart';
import 'package:template_b/feat/auth/data/models/request_model/change_password_request_model.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:common_components/common_components.dart';

/// Provider for change password controller
final changePasswordControllerProvider =
    NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(
      () => ChangePasswordNotifier(),
    );

/// Notifier managing change password logic
class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  late ChangePasswordUseCase _changePasswordUseCase;

  late SecurePreferences _secureStorage;
  late AppPreferenceManager _sharedPreferences;

  @override
  ChangePasswordState build() {
    _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);

    _secureStorage = ref.watch(securePreferencesProvider);
    _sharedPreferences = ref.watch(preferenceManagerProvider);
    return const ChangePasswordState();
  }

  /// Submit password change request
  Future<void> submitPasswordChange({
    required String currentPassword,
    required String newPassword,
    required void Function() onSuccess,
  }) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    try {
      // Create change password request model
      final changePasswordRequest = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Call change password usecase
      final result = await _changePasswordUseCase.call(changePasswordRequest);

      // Handle result
      result.fold(
        (error) {
          // Log error response
          developer.log(
            'Change Password Error: $error',
            name: 'ChangePasswordController.submitPasswordChange',
            error: error,
          );
          state = state.copyWith(
            state: StateEnum.errorSnackBar,
            message: error.toString(),
          );
        },
        (changePasswordResponse) async {
          // Log success response
          developer.log(
            'Change Password Success: ${changePasswordResponse.message}',
            name: 'ChangePasswordController.submitPasswordChange',
          );

          await logout();
          // Handle success
          state = state.copyWith(
            state: StateEnum.success,
            message: changePasswordResponse.message,
          );

          onSuccess();
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: e.toString(),
      );
    }
  }

  /// Reset state to initial
  void reset() {
    state = const ChangePasswordState();
  }

  /// Logout user
  Future<void> logout() async {
    // Clear WebViews from the IndexedStack immediately while the app is
    // foregrounded so Flutter renders the removal frame before GoRouter
    // redirects. Without this, WKWebViews stay alive in BottomNavigation
    // during the redirect window, causing a crash if the user force-quits.
    try {
      ref.read(bottomNavigationProvider.notifier).clearWebViewScreens();
    } catch (_) {}
    ref.read(authStateProvider.notifier).setLoggedOut();
    await clearTokens();
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.remove(StorageKeys.authAccessToken),
      _secureStorage.remove(StorageKeys.authRefreshToken),
      _sharedPreferences.removePreference(StorageKeys.authExpiresIn),
      _sharedPreferences.removePreference(StorageKeys.authRole),
      _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, false),
      _sharedPreferences.removePreference(
        StorageKeys.defectReportLastSelectedLocation,
      ),
      LocalitySelectionController.clearAllPersistedData(_sharedPreferences),
    ]);
    await _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, false);
  }
}
