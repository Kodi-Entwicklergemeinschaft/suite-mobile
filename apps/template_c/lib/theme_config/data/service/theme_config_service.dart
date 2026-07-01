import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';
import '../models/theme_config_response_model.dart';

final themeConfigServiceProvider = Provider<ThemeConfigService>((ref) {
  return ThemeConfigService();
});

class ThemeConfigService {
  Future<AppTheme> getThemeConfig() async {
    dev.log('[ThemeConfigService] Loading theme from local asset');
    final jsonStr = await rootBundle.loadString('assets/config/theme.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final response = ThemeConfigResponseModel().fromJson(data);
    if (response.data == null) throw Exception('No theme data in local asset');
    dev.log('[ThemeConfigService] Loaded theme from asset');
    return response.data!;
  }
}
