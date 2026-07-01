import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/providers/auth_state_provider.dart';
import 'package:template_c/feat/auth/data/models/request_model/login_request_model.dart';
import 'package:template_c/feat/auth/domain/usecases/login_usecase.dart';
import 'package:template_c/feat/auth/state/signin_state.dart';

final signinControllerProvider =
    NotifierProvider<SigninController, SigninState>(() => SigninController());

class SigninController extends Notifier<SigninState> {
  late LoginUseCase _loginUseCase;

  @override
  build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    return SigninState();
  }

  void changeShowPasswordStatus({required bool showPasswordStatus}) {
    state = state.copywith(showPassword: showPasswordStatus);
  }

  void signIn({
    required String userNameOrEmail,
    required String password,
  }) async {
    final prefs = ref.read(preferenceManagerProvider);
    state = state.copywith(state: StateEnum.loadingDialog);

    final deviceId = prefs.getStringOrEmpty(StorageKeys.deviceId);

    final loginRequest = LoginRequestModel(
      usernameOrEmail: userNameOrEmail,
      password: password,
      deviceId: deviceId,
    );

    // Call login usecase
    final result = await _loginUseCase.call(loginRequest);

    // Handle result
    result.fold(
      (error) {
        // Handle error
        state = state.copywith(
          state: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (loginResponse) async {
        ref.read(authStateProvider.notifier).setLoggedIn();
        // Handle success - loginResponse is the direct model
        state = state.copywith(
          state: StateEnum.success,
          message: loginResponse.message,
          isOnboarded: loginResponse.user?.onboarded,
        );
      },
    );
  }
}
