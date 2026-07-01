import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:theme/theme.dart';
import '../../../core/constant/api_endpoints.dart';
import '../../../core/utils/config_mode.dart';
import '../models/theme_config_response_model.dart';

final themeConfigServiceProvider = Provider<ThemeConfigService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ThemeConfigService(apiHelper);
});

class ThemeConfigService {
  final ApiHelper _apiHelper;

  ThemeConfigService(this._apiHelper);

  Future<AppTheme> getThemeConfig() async {
    if (!isLiveMode) {
      final jsonStr = await rootBundle.loadString('assets/config/theme_config.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final response = ThemeConfigResponseModel().fromJson(data);
      if (response.data == null) throw Exception('No theme data in local config');
      return response.data!;
    }

    final result = await _apiHelper.getRequest<ThemeConfigResponseModel>(
      path: ApiEndpoints.themeConfig,
      create: () => ThemeConfigResponseModel(),
    );

    return result.fold(
      (error) => throw error,
      (response) {
        if (response.data == null) throw Exception('No theme data');
        return response.data!;
      },
    );
  }
}
