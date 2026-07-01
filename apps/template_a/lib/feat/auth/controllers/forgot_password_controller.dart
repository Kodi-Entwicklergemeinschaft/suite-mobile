import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordState {
  final StateEnum state;
  final String? message;

  const ForgotPasswordState({
    this.state = StateEnum.initial,
    this.message,
  });

  bool get isSuccess => state == StateEnum.success;

  ForgotPasswordState copyWith({StateEnum? state, String? message}) {
    return ForgotPasswordState(
      state: state ?? this.state,
      message: message,
    );
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>(
  () => ForgotPasswordController(),
);

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  late ForgotPasswordUseCase _forgotPasswordUseCase;

  @override
  ForgotPasswordState build() {
    _forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
    return const ForgotPasswordState();
  }

  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(state: StateEnum.loadingDialog);

    final result = await _forgotPasswordUseCase.call(
      ForgotPasswordRequestModel(username: email),
    );

    result.fold(
      (error) => state = state.copyWith(
        state: StateEnum.errorSnackBar,
        message: error.toString(),
      ),
      (response) => state = state.copyWith(
        state: StateEnum.success,
        message: response.message,
      ),
    );
  }

  void reset() => state = const ForgotPasswordState();
}
