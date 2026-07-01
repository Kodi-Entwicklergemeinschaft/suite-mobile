import 'package:flutter/material.dart';

class ColorGenerator {
  // All default colors defined here - single source of truth
  // Colors sourced from template_b.json branding
  static const defaultPrimary = Color(0xFF3498DB);
  static const defaultSecondary = Color(0xFF2ECC71);
  static const accent = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFE67E22);
  static const lightBackground = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF0D0D0D);
  static const surfaceLight = Color(0xFFECF0F1);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const fontLight = Color(0xFFFFFFFF);
  static const fontDark = Color(0xFF2C3E50);
  static const dividerColor = Color(0xFFE8E8E8);

  static DerivedColors generate() {
    return const DerivedColors(
      accent: accent,
      error: error,
      success: success,
      warning: warning,
      lightBackground: lightBackground,
      darkBackground: darkBackground,
      surfaceLight: surfaceLight,
      surfaceDark: surfaceDark,
      fontLight: fontLight,
      fontDark: fontDark,
      dividerColor: dividerColor,
    );
  }
}

class DerivedColors {
  final Color accent;
  final Color error;
  final Color success;
  final Color warning;
  final Color lightBackground;
  final Color darkBackground;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color fontLight;
  final Color fontDark;
  final Color dividerColor;

  const DerivedColors({
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
}
