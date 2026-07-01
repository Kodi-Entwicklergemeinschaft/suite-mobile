import 'package:flutter/material.dart';

/// Represents the current theme state with mode information.
///
/// Supports three modes:
/// - [ThemeMode.light] - Light theme only
/// - [ThemeMode.dark] - Dark theme only
/// - [ThemeMode.system] - Follow system preference
@immutable
class ThemeState {
  /// The current theme mode
  final ThemeMode mode;

  const ThemeState(this.mode);

  /// Returns true if the theme mode is dark
  bool get isDark => mode == ThemeMode.dark;

  /// Returns true if the theme mode is light
  bool get isLight => mode == ThemeMode.light;

  /// Returns true if the theme mode is system (follows OS preference)
  bool get isSystem => mode == ThemeMode.system;

  /// Converts the theme mode to a string representation
  ///
  /// Returns 'light', 'dark', or 'system'
  String get modeString {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  /// Creates a ThemeMode from a string representation
  ///
  /// Accepts 'light', 'dark', or 'system' (case-insensitive)
  /// Defaults to [ThemeMode.system] if the input is null or invalid
  static ThemeMode themeModeFromString(String? modeString) {
    if (modeString == null) return ThemeMode.system;

    return switch (modeString.toLowerCase()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  @override
  String toString() => 'ThemeState(mode: $modeString)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          mode == other.mode;

  @override
  int get hashCode => mode.hashCode;
}
