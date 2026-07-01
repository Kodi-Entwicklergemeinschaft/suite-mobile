import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/auth/state/signin_state.dart';
import 'package:template_b/feat/auth/domain/usecases/login_usecase.dart';
import 'package:template_b/feat/auth/domain/usecases/guest_register_usecase.dart';
import 'package:template_b/feat/auth/data/models/request_model/login_request_model.dart';
import 'package:template_b/feat/auth/data/models/request_model/guest_register_request_model.dart';

/// Provider for sign in controller
final signInControllerProvider =
    NotifierProvider.autoDispose<SignInNotifier, SignInState>(() {
      return SignInNotifier();
    });

/// Notifier managing sign in logic
class SignInNotifier extends Notifier<SignInState> {
  late LoginUseCase _loginUseCase;
  late GuestRegisterUseCase _guestRegisterUseCase;

  @override
  SignInState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _guestRegisterUseCase = ref.read(guestRegisterUseCaseProvider);
    return SignInState();
  }

  /// Sign in with username/email and password
  /// username parameter can be either username or email
  Future<void> signIn({
    required String usernameOrEmail,
    required String password,
  }) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    final prefs = ref.read(preferenceManagerProvider);
    final deviceId = prefs.getStringOrEmpty(StorageKeys.deviceId);

    final loginRequest = LoginRequestModel(
      username: usernameOrEmail,
      password: password,
      deviceId: deviceId,
    );

    // Call login usecase
    final result = await _loginUseCase.call(loginRequest);

    // Handle result
    result.fold(
      (error) {
        // Handle error
        state = state.copyWith(
          state: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (loginResponse) async {
        ref.read(authStateProvider.notifier).setLoggedIn();
        // Handle success - loginResponse is the direct model
        state = state.copyWith(
          state: StateEnum.success,
          message: loginResponse.message,
        );
      },
    );
  }

  /// Register guest user as permanent user
  Future<void> guestRegister({
    required String guestUserId,
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String tenantId,
  }) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    developer.log(
      'Guest Register Request: guestUserId=$guestUserId, email=$email',
      name: 'SignInController.guestRegister',
    );

    final guestRegisterRequest = GuestRegisterRequestModel(
      guestUserId: guestUserId,
      email: email,
      password: password,
      username: username,
      firstName: firstName,
      lastName: lastName,
      tenantId: tenantId,
    );

    final result = await _guestRegisterUseCase.call(guestRegisterRequest);

    result.fold(
      (error) {
        developer.log(
          'Guest Register Error: $error',
          name: 'SignInController.guestRegister',
          error: error,
        );
        state = state.copyWith(
          state: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (registerResponse) {
        developer.log(
          'Guest Register Success: ${registerResponse.message}',
          name: 'SignInController.guestRegister',
        );
        state = state.copyWith(
          state: StateEnum.success,
          message:
              registerResponse.message ??
              'Registration successful. Please verify your email.',
        );
      },
    );
  }

  /// Reset state to initial
  void reset() {
    state = const SignInState();
  }
}
