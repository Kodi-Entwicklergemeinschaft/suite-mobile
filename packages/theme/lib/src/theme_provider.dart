import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/app_theme.dart' show AppTheme;
import 'theme_service.dart';

/// Cached app theme notifier - loaded during bootstrap
///
/// This Notifier holds the AppTheme object loaded during app initialization.
/// It starts with null and is populated by the bootstrap process.
/// Provides a default theme if not explicitly set.
class _AppThemeNotifier extends Notifier<AppTheme?> {
  @override
  AppTheme? build() {
    return null;
  }

  /// Update the app theme after loading
  void setAppTheme(AppTheme? theme) {
    state = theme;
  }
}

final appThemeNotifierProvider =
    NotifierProvider<_AppThemeNotifier, AppTheme?>(() {
  return _AppThemeNotifier();
});

/// Current app theme provider - contains colors, fonts, and assets
///
/// Synchronous provider that returns app theme with fallback to default.
/// The data is pre-loaded during bootstrap, so this is always synchronous.
/// If theme is not loaded, returns [AppTheme.defaultTheme] as fallback.
/// Actual brightness/theme mode is controlled by [themeServiceProvider],
/// and themes are built on-the-fly using the template-specific buildThemeData() in main.dart.
final appThemeProvider = Provider<AppTheme>((ref) {
  final theme = ref.watch(appThemeNotifierProvider);
  return theme ?? AppTheme.defaultTheme;
});
