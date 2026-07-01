import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom theme extension providing additional theme properties beyond Material ThemeData
///
/// This extension allows apps to define custom colors and spacing that aren't
/// available in the standard Material theme, while maintaining full Material Design
/// compatibility.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// Color used for success states (e.g., success messages, checkmarks)
  final Color? successColor;

  /// Color used for warning states (e.g., warning messages, alerts)
  final Color? warningColor;

  /// Color used for informational states (e.g., info messages, tips)
  final Color? infoColor;

  /// Shadow color used for cards and elevated surfaces
  final Color? cardShadowColor;

  /// Extra spacing value used for additional padding/margins
  /// Typically larger in dark mode for visual comfort
  final double extraSpacing;

  const AppThemeExtension({
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.cardShadowColor,
    this.extraSpacing = 24.0,
  });

  @override
  AppThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? cardShadowColor,
    double? extraSpacing,
  }) {
    return AppThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      extraSpacing: extraSpacing ?? this.extraSpacing,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t),
      extraSpacing: ui.lerpDouble(extraSpacing, other.extraSpacing, t) ?? 24.0,
    );
  }

  /// Retrieves the [AppThemeExtension] from the current context's theme
  ///
  /// Throws an assertion error if the extension is not found (in debug mode)
  static AppThemeExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<AppThemeExtension>();
    assert(extension != null, 'AppThemeExtension not found in theme');
    return extension ?? const AppThemeExtension();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeExtension &&
          runtimeType == other.runtimeType &&
          successColor == other.successColor &&
          warningColor == other.warningColor &&
          infoColor == other.infoColor &&
          cardShadowColor == other.cardShadowColor &&
          extraSpacing == other.extraSpacing;

  @override
  int get hashCode =>
      successColor.hashCode ^
      warningColor.hashCode ^
      infoColor.hashCode ^
      cardShadowColor.hashCode ^
      extraSpacing.hashCode;
}


 // extensions: <ThemeExtension<dynamic>>[
    //   AppThemeExtension(
    //     successColor: const Color(0xFF28A745),
    //     warningColor: const Color(0xFFFFC107),
    //     infoColor: colors.accent,
    //     cardShadowColor: const Color(0x80FFFFFF), // White shadow for dark
    //     extraSpacing: ThemeConstants.defaultExtraSpacingDark,
    //   ),
    // ],