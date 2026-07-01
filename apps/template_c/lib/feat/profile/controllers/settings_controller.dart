import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';
import 'package:template_c/feat/profile/state/settings_state.dart';

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Derive darkModeEnabled from the real theme service so the toggle always
    // reflects the persisted theme, even when the sheet is reopened.
    final themeState = ref.watch(themeServiceProvider);
    final isDark = switch (themeState.mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    return SettingsState(darkModeEnabled: isDark);
  }

  /// Toggles dark mode and persists the choice via [ThemeService].
  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    await ref.read(themeServiceProvider.notifier).toggleTheme(value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(
        () => SettingsController());
