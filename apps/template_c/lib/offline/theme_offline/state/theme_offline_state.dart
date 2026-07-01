import 'package:theme/theme.dart';

class ThemeOfflineState {
  final AppTheme? cachedTheme;

  ThemeOfflineState(this.cachedTheme);

  ThemeOfflineState copyWith({AppTheme? cachedTheme}) {
    return ThemeOfflineState(cachedTheme ?? this.cachedTheme);
  }
}
