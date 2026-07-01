import 'package:flutter/material.dart';

/// Semantic color slots shared by all feature packages and common_components.
///
/// Each template registers its own instance in [buildThemeData] so that feature
/// widgets automatically inherit the correct palette without importing any
/// template-specific package.
class AppFeatureColors extends ThemeExtension<AppFeatureColors> {
  /// Surface color for cards, bottom-sheets, and fact-cards.
  final Color cardBackground;

  /// Background for filter chips and tag containers.
  final Color chipBackground;

  /// Bottom border / divider color used by custom app-bars.
  final Color appBarBorderColor;

  /// Secondary / description text (muted, below headline).
  final Color descriptionText;

  /// Sub-heading grey — labels, small captions.
  final Color subHeadingText;

  /// Disabled or placeholder text (e.g. empty location field).
  final Color disabledText;

  /// Background for active/selected filter chips (e.g. brand accent pill).
  final Color activeChipBackground;

  /// Foreground (text + icons) on [activeChipBackground].
  final Color activeChipForeground;

  const AppFeatureColors({
    required this.cardBackground,
    required this.chipBackground,
    required this.appBarBorderColor,
    required this.descriptionText,
    required this.subHeadingText,
    required this.disabledText,
    required this.activeChipBackground,
    required this.activeChipForeground,
  });

  static const _lightCardBg = Color(0xFFFFFFFF);
  static const _darkCardBg = Color(0xFF171E26);
  static const _lightChipBg = Color(0xFFF8F8F9);
  static const _darkChipBg = Color(0xFF1B262D);
  static const _lightBorder = Color(0xFFEBEBEB);
  static const _darkBorder = Color(0xFF232C39);
  static const _lightDescription = Color(0xFF343434);
  static const _darkDescription = Color(0xFFBABCC5);
  static const _subHeadingGrey = Color(0xFF808080);
  static const _disabledGrey = Color(0xFFB0B0B0);
  static const _activeChipBg = Color(0xFFFFD0E8);
  static const _activeChipFg = Color(0xFF151B23);

  static const light = AppFeatureColors(
    cardBackground: _lightCardBg,
    chipBackground: _lightChipBg,
    appBarBorderColor: _lightBorder,
    descriptionText: _lightDescription,
    subHeadingText: _subHeadingGrey,
    disabledText: _disabledGrey,
    activeChipBackground: _activeChipBg,
    activeChipForeground: _activeChipFg,
  );

  static const dark = AppFeatureColors(
    cardBackground: _darkCardBg,
    chipBackground: _darkChipBg,
    appBarBorderColor: _darkBorder,
    descriptionText: _darkDescription,
    subHeadingText: _subHeadingGrey,
    disabledText: _disabledGrey,
    activeChipBackground: _activeChipBg,
    activeChipForeground: _activeChipFg,
  );

  @override
  AppFeatureColors copyWith({
    Color? cardBackground,
    Color? chipBackground,
    Color? appBarBorderColor,
    Color? descriptionText,
    Color? subHeadingText,
    Color? disabledText,
    Color? activeChipBackground,
    Color? activeChipForeground,
  }) {
    return AppFeatureColors(
      cardBackground: cardBackground ?? this.cardBackground,
      chipBackground: chipBackground ?? this.chipBackground,
      appBarBorderColor: appBarBorderColor ?? this.appBarBorderColor,
      descriptionText: descriptionText ?? this.descriptionText,
      subHeadingText: subHeadingText ?? this.subHeadingText,
      disabledText: disabledText ?? this.disabledText,
      activeChipBackground: activeChipBackground ?? this.activeChipBackground,
      activeChipForeground: activeChipForeground ?? this.activeChipForeground,
    );
  }

  @override
  AppFeatureColors lerp(AppFeatureColors? other, double t) {
    if (other is! AppFeatureColors) return this;
    return AppFeatureColors(
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      chipBackground:
          Color.lerp(chipBackground, other.chipBackground, t) ?? chipBackground,
      appBarBorderColor:
          Color.lerp(appBarBorderColor, other.appBarBorderColor, t) ??
              appBarBorderColor,
      descriptionText: Color.lerp(descriptionText, other.descriptionText, t) ??
          descriptionText,
      subHeadingText:
          Color.lerp(subHeadingText, other.subHeadingText, t) ?? subHeadingText,
      disabledText:
          Color.lerp(disabledText, other.disabledText, t) ?? disabledText,
      activeChipBackground:
          Color.lerp(activeChipBackground, other.activeChipBackground, t) ??
              activeChipBackground,
      activeChipForeground:
          Color.lerp(activeChipForeground, other.activeChipForeground, t) ??
              activeChipForeground,
    );
  }

  static AppFeatureColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppFeatureColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }
}
