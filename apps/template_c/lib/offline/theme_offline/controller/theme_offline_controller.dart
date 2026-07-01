import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/offline/core/box_constant.dart';
import 'package:preference_manager/hive_service.dart';
import 'package:template_c/offline/theme_offline/state/theme_offline_state.dart';
import 'package:theme/theme.dart';

final themeOfflineControllerProvider =
    NotifierProvider<ThemeOfflineController, ThemeOfflineState>(
      () => ThemeOfflineController(),
    );

class ThemeOfflineController extends Notifier<ThemeOfflineState> {
  static String get _boxName => BoxKey.templateC.name;
  static String get _themeKey => BoxItemKeyConstant.themeKey.name;

  @override
  ThemeOfflineState build() {
    return ThemeOfflineState(null);
  }

  Future<void> cacheTheme(AppTheme theme) async {
    try {
      await HiveService.instance.put<dynamic>(
        _boxName,
        _themeKey,
        theme.toJson(),
      );
      state = state.copyWith(cachedTheme: theme);
      debugPrint('ThemeOffline: theme cached');
    } catch (e) {
      debugPrint('ThemeOffline: cacheTheme error → $e');
    }
  }

  Future<AppTheme?> getCachedTheme() async {
    try {
      final raw = await HiveService.instance.get<dynamic>(_boxName, _themeKey);
      if (raw == null) return null;
      final theme = AppTheme.fromJson(_deepCastMap(raw as Map));
      state = state.copyWith(cachedTheme: theme);
      return theme;
    } catch (e) {
      debugPrint('ThemeOffline: getCachedTheme error → $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await HiveService.instance.remove<dynamic>(_boxName, _themeKey);
      state = ThemeOfflineState(null);
      debugPrint('ThemeOffline: cache cleared');
    } catch (e) {
      debugPrint('ThemeOffline: clearCache error → $e');
    }
  }

  Map<String, dynamic> _deepCastMap(Map map) {
    return map.map((key, value) {
      final castValue = switch (value) {
        Map() => _deepCastMap(value),
        List() => _deepCastList(value),
        _ => value,
      };
      return MapEntry(key.toString(), castValue);
    });
  }

  dynamic _deepCastList(List list) {
    return list.map((e) {
      if (e is Map) return _deepCastMap(e);
      if (e is List) return _deepCastList(e);
      return e;
    }).toList();
  }
}
