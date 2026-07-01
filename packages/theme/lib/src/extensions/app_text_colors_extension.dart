import 'package:flutter/material.dart';

class AppTextColors extends ThemeExtension<AppTextColors> {
  final Color normal;
  final Color inverse;

  const AppTextColors({
    required this.normal,
    required this.inverse,
  });

  @override
  AppTextColors copyWith({Color? normal, Color? inverse}) {
    return AppTextColors(
      normal: normal ?? this.normal,
      inverse: inverse ?? this.inverse,
    );
  }

  @override
  AppTextColors lerp(AppTextColors? other, double t) {
    if (other is! AppTextColors) {
      return this;
    }
    return AppTextColors(
      normal: Color.lerp(normal, other.normal, t) ?? normal,
      inverse: Color.lerp(inverse, other.inverse, t) ?? inverse,
    );
  }

  static AppTextColors of(BuildContext context) {
    return Theme.of(context).extension<AppTextColors>()!;
  }
}
