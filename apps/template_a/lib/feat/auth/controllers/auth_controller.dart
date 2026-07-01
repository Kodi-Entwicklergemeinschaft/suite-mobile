import 'dart:ui' show Locale;

import 'package:common_components/common_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localization_controller.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/data/models/login_request_model.dart';
import 'package:template_a/feat/auth/data/models/register_request_model.dart';
import 'package:template_a/feat/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:template_a/feat/auth/domain/usecases/guest_login_usecase.dart';
import 'package:template_a/feat/auth/domain/usecases/login_usecase.dart';
import 'package:template_a/feat/auth/domain/usecases/register_usecase.dart';
import 'package:template_a/feat/auth/state/auth_state.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_language_preference_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/update_language_usecase.dart';

import '../../../core/providers/auth_state_provider.dart';
import '../../../core/widgets/user_type_card.dart';
import '../services/auth_service.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() => AuthController());

class AuthController extends Notifier<AuthState> {
  late LoginUseCase _loginUseCase;
  late GuestLoginUseCase _guestLoginUseCase;
  late RegisterUseCase _registerUseCase;
  late ForgotPasswordUseCase _forgotPasswordUseCase;
  late GetLanguagePreferenceUseCase _getLanguagePreferenceUseCase;
  late UpdateLanguageUseCase _updateLanguageUseCase;

  @override
  AuthState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _guestLoginUseCase = ref.read(guestLoginUseCaseProvider);
    _registerUseCase = ref.read(registerUseCaseProvider);
    _forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
    _getLanguagePreferenceUseCase = ref.read(getLanguagePreferenceUseCaseProvider);
    _updateLanguageUseCase = ref.read(updateLanguageUseCaseProvider);
    return AuthState();
  }

  void setUserType(UserTypeEnum userType) {
    state = state.copyWith(userType: userType);
  }

  void clearUserType() {
    state = AuthState(
      state: state.state,
      message: state.message,
      userType: null,
      isOnboarded: state.isOnboarded,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(state: StateEnum.loading);

    final request = LoginRequestModel(
      email: email,
      password: password,
    );

    final result = await _loginUseCase.call(request);

    if (result.isLeft()) {
      state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: result.fold((e) => e.toString(), (_) => ''),
      );
      return;
    }

    final response = result.getOrElse(() => throw Exception());
    final prefs = ref.read(preferenceManagerProvider);
    prefs.saveBool(StorageKeys.authIsGuest, false);
    if (response.onboarded == true) {
      prefs.saveBool(StorageKeys.isOnboarded, true);
      prefs.saveBool(StorageKeys.isTermsAndConditionAccepted, true);
      prefs.saveBool(StorageKeys.isUserPreferencesSet, true);
    }
    ref.read(authStateProvider.notifier).setLoggedIn();
    await _syncLanguageAfterAuth();
    if (!ref.mounted) return;
    state = state.copyWith(
      state: StateEnum.success,
      message: response.message ?? 'Login successful',
      isOnboarded: response.onboarded,
    );
  }

  Future<void> guestLogin() async {
    state = state.copyWith(state: StateEnum.loading);

    final prefs = ref.read(preferenceManagerProvider);
    var deviceId = prefs.getStringOrNull(StorageKeys.deviceId);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = await DeviceInfoController.getDeviceUUID();
      if (deviceId == null || deviceId.isEmpty) {
        state = state.copyWith(
          state: StateEnum.errorSnackBar,
          message: 'Could not get device ID',
        );
        return;
      }
      await prefs.saveString(StorageKeys.deviceId, deviceId);
    }

    final result = await _guestLoginUseCase.call(deviceId: deviceId);

    if (result.isLeft()) {
      state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: result.fold((e) => e.toString(), (_) => ''),
      );
      return;
    }

    final response = result.getOrElse(() => throw Exception());
    prefs.saveBool(StorageKeys.authIsGuest, true);
    prefs.saveBool(StorageKeys.isTermsAndConditionAccepted, false);
    prefs.saveBool(StorageKeys.isOnboarded, false);
    prefs.saveBool(StorageKeys.isUserPreferencesSet, false);
    ref.read(authStateProvider.notifier).setLoggedIn();
    await _syncLanguageAfterAuth();
    if (!ref.mounted) return;
    state = state.copyWith(
      state: StateEnum.success,
      message: response.message ?? 'Guest login successful',
    );
  }

  void register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(state: StateEnum.loading);

    final request = RegisterRequestModel(
      email: email,
      password: password,
    );

    final result = await _registerUseCase.call(request);

    result.fold(
      (error) => state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: error.toString(),
      ),
      (response) {
        state = state.copyWith(
          state: StateEnum.success,
          message: response.message ?? 'Registration successful',
        );
      },
    );
  }

  void forgotPassword({
    required String email,
  }) async {
    state = state.copyWith(state: StateEnum.loading);

    final request = ForgotPasswordRequestModel(
      username: email,
    );

    final result = await _forgotPasswordUseCase.call(request);

    result.fold(
      (error) => state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: error.toString(),
      ),
      (response) => state = state.copyWith(
        state: StateEnum.success,
        message: response.message ?? 'Password reset email sent',
      ),
    );
  }

  void resetState() {
    state = state.copyWith(state: StateEnum.initial, message: null);
  }

  Future<void> clearGuestSession() async {
    await ref.read(authServiceProvider).clearTokens();
    final prefs = ref.read(preferenceManagerProvider);
    prefs.saveBool(StorageKeys.authIsGuest, false);
    prefs.saveBool(StorageKeys.isTermsAndConditionAccepted, false);
    prefs.saveString('locale', '');
    ref.read(authStateProvider.notifier).setLoggedOut();
  }

  Future<void> _syncLanguageAfterAuth() async {
    final result = await _getLanguagePreferenceUseCase.call(const NoParams());
    if (!ref.mounted) return;

    result.fold(
      (_) {
        // API failed: persist whatever language is currently active so next boot uses it
        ref.read(preferenceManagerProvider).saveString('locale', ref.read(localizationControllerProvider).languageCode);
      },
      (langResponse) {
        final preferred = langResponse.data?.preferredLanguage;
        final currentLang = ref.read(localizationControllerProvider).languageCode;

        if (preferred != null && preferred.isNotEmpty) {
          if (preferred != currentLang) {
            ref.read(localizationControllerProvider.notifier).changeLocale(Locale(preferred));
            ref.read(bottomNavigationProvider.notifier).refreshLabels();
          } else {
            ref.read(preferenceManagerProvider).saveString('locale', preferred);
          }
        } else {
          ref.read(preferenceManagerProvider).saveString('locale', currentLang);
          _updateLanguageUseCase.call(UpdateLanguageParams(currentLang));
        }
      },
    );
  }
}
