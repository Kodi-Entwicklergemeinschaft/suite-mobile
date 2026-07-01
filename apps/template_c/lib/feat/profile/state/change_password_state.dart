import 'package:template_c/core/constant/common_enums.dart';

/// State representing change password process
class ChangePasswordState {
  final StateEnum state;
  final String? message;

  const ChangePasswordState({
    this.state = StateEnum.initial,
    this.message,
  });

  bool get isLoading => state.isLoading;
  bool get isSuccess => state == StateEnum.success;
  bool get hasError =>
      state == StateEnum.error || state == StateEnum.errorSnackBar;

  ChangePasswordState copyWith({
    StateEnum? state,
    String? message,
  }) {
    return ChangePasswordState(
      state: state ?? this.state,
      message: message,
    );
  }
}
