import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'theme_provider.dart';
import 'theme_state.dart';
import 'theme_constants.dart';

/// Service for managing theme state with persistence
///
/// Handles switching between light, dark, and system theme modes
/// and persists the user's preference to local storage via PreferenceManager.
class ThemeService extends Notifier<ThemeState> {
  late PreferenceManager _prefs;

  @override
  ThemeState build() {
    _prefs = ref.watch(preferenceManagerProvider);
    return _loadPersistedTheme();
  }

  /// Loads the persisted theme mode from storage.
  ///
  /// Returns the saved theme state, or defaults to [ThemeMode.system]
  /// if no preference is found or an error occurs.
  ThemeState _loadPersistedTheme() {
    try {
      final savedMode =
          _prefs.getStringOrNull(ThemeConstants.themeModeKey);
      final mode = ThemeState.themeModeFromString(savedMode);
      return ThemeState(mode);
    } catch (e) {
      debugPrint('Error loading persisted theme: $e');
      return const ThemeState(ThemeMode.light);
    }
  }

  /// Toggles between light and dark themes based on the provided [isDark] flag
  ///
  /// - If [isDark] is true, switches to dark theme
  /// - If [isDark] is false, switches to light theme
  /// System theme mode is not affected by this toggle
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _updateTheme(newMode);
  }

  /// Sets the theme mode to light
  Future<void> setLightTheme() async {
    await _updateTheme(ThemeMode.light);
  }

  /// Sets the theme mode to dark
  Future<void> setDarkTheme() async {
    await _updateTheme(ThemeMode.dark);
  }

  /// Sets the theme mode to system (follows device preference)
  Future<void> setSystemTheme() async {
    await _updateTheme(ThemeMode.system);
  }

  /// Updates the theme mode and persists it to storage
  ///
  /// Internal method called by public theme-setting methods.
  /// Updates both the state (for UI reactivity) and persistent storage.
  Future<void> _updateTheme(ThemeMode mode) async {
    try {
      // Update state for UI reactivity
      state = ThemeState(mode);

      // Persist to storage
      await _prefs.saveString(ThemeConstants.themeModeKey, mode.name);
    } catch (e) {
      debugPrint('Error updating theme: $e');
      // Revert to previous state on error
      rethrow;
    }
  }
}

/// Riverpod provider for theme service
///
/// Manages theme state with automatic persistence.
///
/// Usage:
/// ```dart
/// final themeState = ref.watch(themeServiceProvider);
/// ref.read(themeServiceProvider.notifier).setDarkTheme();
/// ```
final themeServiceProvider = NotifierProvider<ThemeService, ThemeState>(() {
  return ThemeService();
});
