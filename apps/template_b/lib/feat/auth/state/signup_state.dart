import 'package:template_b/core/constants/common_enums.dart';

/// State representing sign up process
class SignUpState {
  final StateEnum state;
  final String? message;

  const SignUpState({
    this.state = StateEnum.initial,
    this.message,
  });

  bool get isLoading => state.isLoading;
  bool get isSuccess => state == StateEnum.success;
  bool get hasError =>
      state == StateEnum.error || state == StateEnum.errorSnackBar;

  SignUpState copyWith({
    StateEnum? state,
    String? message,
  }) {
    return SignUpState(
      state: state ?? this.state,
      message: message,
    );
  }
}
