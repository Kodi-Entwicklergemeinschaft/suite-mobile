import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/state/signup_state.dart';
import 'package:template_b/feat/auth/domain/usecases/register_usecase.dart';
import 'package:template_b/feat/auth/data/models/register_request_model.dart';

/// Provider for sign up controller
final signUpControllerProvider =
    NotifierProvider.autoDispose<SignUpNotifier, SignUpState>(() {
      return SignUpNotifier();
    });

/// Notifier managing sign up logic
class SignUpNotifier extends Notifier<SignUpState> {
  late RegisterUseCase _registerUseCase;

  @override
  SignUpState build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    return const SignUpState();
  }

  /// Register new user
  Future<void> signUp({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    try {
      // Create register request model
      final registerRequest = RegisterRequestModel(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Call register usecase
      final result = await _registerUseCase.call(registerRequest);

      // Handle result
      result.fold(
        (error) {
          // Log error response
          developer.log(
            'Register Error: $error',
            name: 'SignUpController.signUp',
            error: error,
          );
          state = state.copyWith(
            state: StateEnum.errorSnackBar,
            message: error.toString(),
          );
        },
        (result) {
          // Log success response
          developer.log(
            'Register Success',
            name: 'SignUpController.signUp',
          );
          // Handle success - user registered but not logged in (no tokens)
          state = state.copyWith(
            state: StateEnum.success,
            message: result.message,
          );
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
    state = const SignUpState();
  }
}
