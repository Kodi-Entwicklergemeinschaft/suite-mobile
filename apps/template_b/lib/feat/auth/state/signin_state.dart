import 'package:template_b/core/constants/common_enums.dart';

/// State representing sign in process
class SignInState {
  final StateEnum state;
  final String? message;

  const SignInState({
    this.state = StateEnum.initial,
    this.message,
  });

  bool get isLoading => state.isLoading;
  bool get isSuccess => state == StateEnum.success;
  bool get hasError =>
      state == StateEnum.error || state == StateEnum.errorSnackBar;

  SignInState copyWith({
    StateEnum? state,
    String? message,
  }) {
    return SignInState(
      state: state ?? this.state,
      message: message,
    );
  }
}
