import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/state/forgot_password_state.dart';
import 'package:template_b/feat/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:template_b/feat/auth/data/models/request_model/forgot_password_request_model.dart';

/// Provider for forgot password controller
final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
      () {
        return ForgotPasswordNotifier();
      },
    );

/// Notifier managing forgot password logic
class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  late ForgotPasswordUseCase _forgotPasswordUseCase;

  @override
  ForgotPasswordState build() {
    _forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
    return const ForgotPasswordState();
  }

  /// Request password reset for username
  Future<void> resetPassword({required String username}) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    final resetRequest = ForgotPasswordRequestModel(
      username: username,
    );

    // Call forgot password usecase
    final result = await _forgotPasswordUseCase.call(resetRequest);

    // Handle result
    result.fold(
      (error) {
        // Handle error
        state = state.copyWith(
          state: StateEnum.errorSnackBar,
          message: error.toString(),
        );
      },
      (resetResponse) {
        // Handle success
        state = state.copyWith(
          state: StateEnum.success,
          message: resetResponse.message,
        );
      },
    );
  }

  /// Reset state to initial
  void reset() {
    state = const ForgotPasswordState();
  }
}
