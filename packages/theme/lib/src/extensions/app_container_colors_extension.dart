import 'package:flutter/material.dart';

class AppContainerColors extends ThemeExtension<AppContainerColors> {
  final Color normal;
  final Color inverse;

  const AppContainerColors({
    required this.normal,
    required this.inverse,
  });

  @override
  AppContainerColors copyWith({Color? normal, Color? inverse}) {
    return AppContainerColors(
      normal: normal ?? this.normal,
      inverse: inverse ?? this.inverse,
    );
  }

  @override
  AppContainerColors lerp(AppContainerColors? other, double t) {
    if (other is! AppContainerColors) {
      return this;
    }
    return AppContainerColors(
      normal: Color.lerp(normal, other.normal, t) ?? normal,
      inverse: Color.lerp(inverse, other.inverse, t) ?? inverse,
    );
  }

  static AppContainerColors of(BuildContext context) {
    return Theme.of(context).extension<AppContainerColors>()!;
  }
}
