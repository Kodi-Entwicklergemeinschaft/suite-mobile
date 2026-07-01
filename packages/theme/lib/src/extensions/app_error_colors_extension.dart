import 'package:flutter/material.dart';

class AppErrorColors extends ThemeExtension<AppErrorColors> {
  final Color success;
  final Color warning;
  final Color error;

  const AppErrorColors({
    required this.success,
    required this.warning,
    required this.error,
  });

  @override
  AppErrorColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppErrorColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppErrorColors lerp(AppErrorColors? other, double t) {
    if (other is! AppErrorColors) {
      return this;
    }
    return AppErrorColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
    );
  }

  static AppErrorColors of(BuildContext context) {
    return Theme.of(context).extension<AppErrorColors>()!;
  }
}
