import 'package:flutter/material.dart';

class TemplateCColors {
  //Scaffold background
  static const lightModeBackground = Color(0xFFFFFFFF);
  static const darkModeBackground = Color(0xFF0B0F13);

  //Chip Colors
  static const lightModeChipBg = Color(0xFFF8F8F9);
  static const darkModeChipBg = Color(0xFF1B262D);

  //Card Colors
  static const lightModeCardBg = Color(0xFFFFFFFF);
  static const darkModeCardBg = Color(0xFF171E26);

  //Text Colors
  static const textBlue = Color(0xFF0280FF);
  static const textPurple = Color(0xFF7C5AE2);
  static const textPink = Color(0xFFFFD0E8);
  static const textAndIconWhite = Color(0xFFF1F2F3);
  static const textAndIconGray = Color(0xFF6C6E7A);
  static const textGrayV2 = Color(0xFF798CA3);
  static const textDark = Color(0xFF151B23);
  static const subHeadingGrey = Color(0xFF808080);
  static const textDescriptionDark = Color(0xFF343434);
  static const textDescriptionLight = Color(0xFFBABCC5);

  //Bg
  static const primaryBlue = Color(0xFF1C4EFF);
  static const primaryPink = Color(0xFFFFD0E8);

  //Button
  static const buttonRed = Color(0xFFFF1C1C);
}

class TemplateCThemeColors extends ThemeExtension<TemplateCThemeColors> {
  final Color bgColor;
  final Color chipBg;
  final Color surfaceBg;
  final TextTheme? secondaryTextTheme;
  final Gradient? splashGradient;

  const TemplateCThemeColors({
    required this.bgColor,
    required this.chipBg,
    required this.surfaceBg,
    this.secondaryTextTheme,
    this.splashGradient,
  });

  static const light = TemplateCThemeColors(
    bgColor: TemplateCColors.lightModeBackground,
    chipBg: TemplateCColors.lightModeChipBg,
    surfaceBg: TemplateCColors.lightModeCardBg,
  );

  static const dark = TemplateCThemeColors(
    bgColor: TemplateCColors.darkModeBackground,
    chipBg: TemplateCColors.darkModeChipBg,
    surfaceBg: TemplateCColors.darkModeCardBg,
  );

  @override
  TemplateCThemeColors copyWith({
    Color? bgColor,
    Color? chipBg,
    Color? surfaceBg,
    TextTheme? secondaryTextTheme,
    Gradient? splashGradient,
  }) {
    return TemplateCThemeColors(
      bgColor: bgColor ?? this.bgColor,
      chipBg: chipBg ?? this.chipBg,
      surfaceBg: surfaceBg ?? this.surfaceBg,
      secondaryTextTheme: secondaryTextTheme ?? this.secondaryTextTheme,
      splashGradient: splashGradient ?? this.splashGradient,
    );
  }

  @override
  TemplateCThemeColors lerp(TemplateCThemeColors? other, double t) {
    if (other == null) return this;
    return TemplateCThemeColors(
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
      secondaryTextTheme: t < 0.5
          ? secondaryTextTheme
          : other.secondaryTextTheme,
      splashGradient: t < 0.5 ? splashGradient : other.splashGradient,
    );
  }
}

extension TemplateCThemeColorsX on BuildContext {
  TemplateCThemeColors get templateColors =>
      Theme.of(this).extension<TemplateCThemeColors>()!;
}
