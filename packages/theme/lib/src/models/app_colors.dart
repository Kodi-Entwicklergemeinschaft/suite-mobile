import 'package:flutter/material.dart';

import '../color_generator.dart';

class AppColors {
  // Brand colors (constant across light/dark)
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color error;

  // Semantic colors (constant across light/dark)
  final Color success;
  final Color warning;

  // Background pairs (light/dark)
  final Color lightBackground;
  final Color darkBackground;

  // Surface pairs (light/dark)
  final Color surfaceLight;
  final Color surfaceDark;

  // Font pairs (light/dark)
  final Color fontLight;
  final Color fontDark;

  // Divider color
  final Color dividerColor;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.error,
    required this.success,
    required this.warning,
    required this.lightBackground,
    required this.darkBackground,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.fontLight,
    required this.fontDark,
    required this.dividerColor,
  });

  factory AppColors.fromJson(Map<String, dynamic> json) {
    // Generate derived colors as fallback
    final derived = ColorGenerator.generate();

    return AppColors(
      primary: json['primaryColor'] != null
          ? _parseColor(json['primaryColor'])
          : ColorGenerator.defaultPrimary,
      secondary: json['secondaryColor'] != null
          ? _parseColor(json['secondaryColor'])
          : ColorGenerator.defaultSecondary,
      accent: json['accentColor'] != null
          ? _parseColor(json['accentColor'])
          : derived.accent,
      error: json['errorColor'] != null
          ? _parseColor(json['errorColor'])
          : derived.error,
      success: json['successColor'] != null
          ? _parseColor(json['successColor'])
          : derived.success,
      warning: json['warningColor'] != null
          ? _parseColor(json['warningColor'])
          : derived.warning,
      lightBackground: json['lightBackground'] != null
          ? _parseColor(json['lightBackground'])
          : derived.lightBackground,
      darkBackground: json['darkBackground'] != null
          ? _parseColor(json['darkBackground'])
          : derived.darkBackground,
      surfaceLight: json['surfaceLight'] != null
          ? _parseColor(json['surfaceLight'])
          : derived.surfaceLight,
      surfaceDark: json['surfaceDark'] != null
          ? _parseColor(json['surfaceDark'])
          : derived.surfaceDark,
      fontLight: json['fontLight'] != null
          ? _parseColor(json['fontLight'])
          : derived.fontLight,
      fontDark: json['fontDark'] != null
          ? _parseColor(json['fontDark'])
          : derived.fontDark,
      dividerColor: json['dividerColor'] != null
          ? _parseColor(json['dividerColor'])
          : ColorGenerator.dividerColor,
    );
  }

  static Color _parseColor(String hex) {
    final cleanHex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  // Helper methods to get colors based on brightness
  Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  Color getTextColor(bool isDark) => isDark ? fontLight : fontDark;
  Color getTextSecondary(bool isDark) {
    final textColor = getTextColor(isDark);
    return textColor.withAlpha((textColor.alpha * 0.7).toInt());
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': _colorToHex(primary),
      'secondaryColor': _colorToHex(secondary),
      'accentColor': _colorToHex(accent),
      'errorColor': _colorToHex(error),
      'successColor': _colorToHex(success),
      'warningColor': _colorToHex(warning),
      'lightBackground': _colorToHex(lightBackground),
      'darkBackground': _colorToHex(darkBackground),
      'surfaceLight': _colorToHex(surfaceLight),
      'surfaceDark': _colorToHex(surfaceDark),
      'fontLight': _colorToHex(fontLight),
      'fontDark': _colorToHex(fontDark),
      'dividerColor': _colorToHex(dividerColor),
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0')}';
  }

  // Default theme - uses ColorGenerator as single source of truth
  static const defaultColors = AppColors(
    primary: ColorGenerator.defaultPrimary,
    secondary: ColorGenerator.defaultSecondary,
    accent: ColorGenerator.accent,
    error: ColorGenerator.error,
    success: ColorGenerator.success,
    warning: ColorGenerator.warning,
    lightBackground: ColorGenerator.lightBackground,
    darkBackground: ColorGenerator.darkBackground,
    surfaceLight: ColorGenerator.surfaceLight,
    surfaceDark: ColorGenerator.surfaceDark,
    fontLight: ColorGenerator.fontLight,
    fontDark: ColorGenerator.fontDark,
    dividerColor: ColorGenerator.dividerColor,
  );
}
