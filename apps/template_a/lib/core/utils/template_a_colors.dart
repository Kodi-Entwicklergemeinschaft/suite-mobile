import 'package:flutter/material.dart';

class TemplateAColors {
  // Primary colors
  static const Color primary = Color(0xFF0C91CF);
  static const Color secondary = Color(0xFFE7F1F6);
  static const Color darkCard = Color(0xFF2C4158);
  static const Color success = Color(0xFF28A745);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF343A40);
  static const Color surface = Color(0xFF212529);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color lightShadow = Color(0x1A000000);
  static const Color darkShadow = Color(0x80FFFFFF);
  static const Color lightSecondary = Color(0xFFB0BEC5);
  static const Color pink = Color(0xFFE30059);

  // Title backgrounds
  static const Color serviceTitleBackground = Color(0xFFB0CB52);
  static const Color shoppingTitleBackground = Color(0xFFE30059);
  static const Color administrationTitleBackground = Color(0xFF728ABB);
  static const Color eventCategoryBackground = Color(0xFF4C89B5);

  // Text field
  static const Color textFieldLightColor = Color.fromRGBO(166, 166, 166, 0.3);

  // Font colors
  static const Color fontLight = Colors.white;
  static const Color fontDark = Colors.black;

  // Theme colors
  static const Color dark = Color(0xFF00223F);
  static const Color light = Color(0xFFE7F1F6);

  // Error colors
  static const Color errorDarkMode = Color(0xFFF89B9B);
  static const Color errorLightMode = Color(0xFFB3261E);

  // Scaffold background
  static const Color lightModeBackground = Color(0xFFE7F1F6);
  static const Color darkModeBackground = Color(0xFF00223F);

  // Chip Colors
  static const Color lightModeChipBg = Color(0xFFF8F8F9);
  static const Color darkModeChipBg = Color(0xFF1B262D);

  // Card Colors
  static const Color lightModeCardBg = Color(0xFFFFFFFF);
  static const Color darkModeCardBg = Color(0xFF171E26);

  // Text Colors (custom)
  static const Color textBlue = Color(0xFF0280FF);
  static const Color textPurple = Color(0xFF7C5AE2);
  static const Color textPink = Color(0xFFFFD0E8);
  static const Color textAndIconWhite = Color(0xFFF1F2F3);
  static const Color textAndIconGray = Color(0xFF6C6E7A);

  // Background colors (custom)
  static const Color primaryBlue = Color(0xFF1C4EFF);
  static const Color primaryPink = Color(0xFFFFD0E8);

  // Button
  static const Color buttonRed = Color(0xFFFF1C1C);

  // Card label spacing — right gap so labels never bleed to the card edge.
  // Apply as `TemplateAColors.cardLabelRightGap.w` wherever a card label
  // (tag chip, title band, subtitle band) is positioned from the left edge.
  static const double cardLabelRightGap = 40;
}

class TemplateAThemeColors extends ThemeExtension<TemplateAThemeColors> {
  final Color bgColor;
  final Color chipBg;
  final Color surfaceBg;

  const TemplateAThemeColors({
    required this.bgColor,
    required this.chipBg,
    required this.surfaceBg,
  });

  static const light = TemplateAThemeColors(
    bgColor: TemplateAColors.lightModeBackground,
    chipBg: TemplateAColors.lightModeChipBg,
    surfaceBg: TemplateAColors.lightModeCardBg,
  );

  static const dark = TemplateAThemeColors(
    bgColor: TemplateAColors.darkModeBackground,
    chipBg: TemplateAColors.darkModeChipBg,
    surfaceBg: TemplateAColors.darkModeCardBg,
  );

  @override
  TemplateAThemeColors copyWith({Color? bgColor, Color? chipBg, Color? surfaceBg}) {
    return TemplateAThemeColors(
      bgColor: bgColor ?? this.bgColor,
      chipBg: chipBg ?? this.chipBg,
      surfaceBg: surfaceBg ?? this.surfaceBg,
    );
  }

  @override
  TemplateAThemeColors lerp(TemplateAThemeColors? other, double t) {
    if (other == null) return this;
    return TemplateAThemeColors(
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
    );
  }
}

extension TemplateAThemeColorsX on BuildContext {
  TemplateAThemeColors get templateColors =>
      Theme.of(this).extension<TemplateAThemeColors>()!;
}
