import 'package:template_b/core/constants/common_enums.dart';

/// State representing forgot password process
class ForgotPasswordState {
  final StateEnum state;
  final String? message;

  const ForgotPasswordState({
    this.state = StateEnum.initial,
    this.message,
  });

  bool get isLoading => state.isLoading;
  bool get isSuccess => state == StateEnum.success;
  bool get hasError =>
      state == StateEnum.error || state == StateEnum.errorSnackBar;

  ForgotPasswordState copyWith({
    StateEnum? state,
    String? message,
  }) {
    return ForgotPasswordState(
      state: state ?? this.state,
      message: message,
    );
  }
}
