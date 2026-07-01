import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/feat/auth/data/models/register_request_model.dart';
import 'package:template_c/feat/auth/domain/usecases/register_usecase.dart';
import 'package:template_c/feat/auth/state/signup_state.dart';

final signupControllerProvider = NotifierProvider<SignupController, SignupState>(()=>SignupController());  

class SignupController extends Notifier<SignupState> {

  late RegisterUseCase _registerUseCase;

  @override
  build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    return SignupState();
  }

  void changeShowPasswordStatus ({required bool showPasswordStatus}) {
    state = state.copywith(showPassword:  showPasswordStatus);
  }

  void changeShowConfirmPasswordStatus ({required bool showConfirmPasswordStatus}) {
    state = state.copywith(showConfirmPassword:  showConfirmPasswordStatus);
  }

  void signUp (
    {
      required String userName, 
      required String email, 
      required String password, 
      required String confirmPassword
    }
    ) async {
    state = state.copywith(state: StateEnum.loadingDialog);

    try {
      // Create register request model
      final registerRequest = RegisterRequestModel(
        email: email,
        username: userName,
        password: password,
      );

      // Call register usecase
      final result = await _registerUseCase.call(registerRequest);

      // Handle result
      result.fold(
        (error) {
          // Log error response
          developer.log(
            'Register Error: $error',
            name: 'SignupController.signUp',
            error: error,
          );
          state = state.copywith(
            state: StateEnum.errorSnackBar,
            message: error.toString(),
          );
        },
        (result) {
          // Log success response
          developer.log(
            'Register Success',
            name: 'SignupController.signUp',
          );
          // Handle success - user registered but not logged in (no tokens)
          state = state.copywith(
            state: StateEnum.success,
            message: result.message,
          );
        },
      );
    } catch (e) {
      state = state.copywith(
        state: StateEnum.errorSnackBar,
        message: e.toString(),
      );
    }
  }
  
}
