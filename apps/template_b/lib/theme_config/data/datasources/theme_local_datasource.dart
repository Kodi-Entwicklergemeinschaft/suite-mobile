import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:theme/theme.dart';

abstract class ThemeLocalDataSource {
  /// Get cached theme config
  /// Returns null if no cache exists
  Future<AppTheme?> getCached();

  /// Cache theme config locally
  Future<void> cache(AppTheme data);

  /// Clear cached theme config
  Future<void> clearCache();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final PreferenceManager preferenceManager;
  static const _cacheKey = 'theme_config_cache';

  ThemeLocalDataSourceImpl({required this.preferenceManager});

  @override
  Future<AppTheme?> getCached() async {
    try {
      final cached = preferenceManager.getStringOrNull(_cacheKey);
      if (cached == null) return null;
      final jsonData = jsonDecode(cached) as Map<String, dynamic>;
      return AppTheme.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cache(AppTheme data) async {
    try {
      await preferenceManager.saveString(_cacheKey, jsonEncode(data.toJson()));
    } catch (e) {
      throw Exception('Failed to cache theme config: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await preferenceManager.removePreference(_cacheKey);
    } catch (e) {
      throw Exception('Failed to clear theme cache: $e');
    }
  }
}

final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  final preferenceManager = ref.watch(preferenceManagerProvider);
  return ThemeLocalDataSourceImpl(preferenceManager: preferenceManager);
});
