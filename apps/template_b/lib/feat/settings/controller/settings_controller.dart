import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/settings/state/settings_state.dart';
import 'package:theme/theme.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() => SettingsNotifier());

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final initialTheme = ref.read(themeServiceProvider);
    ref.listen(themeServiceProvider, (_, next) {
      state = state.copyWith(isDarkMode: _isDarkFromMode(next.mode));
    });

    return SettingsState(isDarkMode: _isDarkFromMode(initialTheme.mode));
  }

  bool _isDarkFromMode(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
  };

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    await ref.read(themeServiceProvider.notifier).toggleTheme(value);
  }

  Future<void> refreshDevicePermissionStatus() async {
    state = state.copyWith(isNotificationEnabled: false);
  }

  Future<void> recheckDeviceNotificationPermission() async {
    state = state.copyWith(isNotificationEnabled: false);
  }
}
