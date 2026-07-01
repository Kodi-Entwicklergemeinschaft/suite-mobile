import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/theme_config/data/models/theme_config_response_model.dart';
import 'package:theme/theme.dart';

abstract class ThemeRemoteDataSource {
  Future<Either<Exception, ThemeConfigResponseModel>> fetchThemeConfig();
}

class ThemeRemoteDataSourceImpl implements ThemeRemoteDataSource {
  ThemeRemoteDataSourceImpl(ApiHelper _);

  @override
  Future<Either<Exception, ThemeConfigResponseModel>> fetchThemeConfig() async {
    try {
      dev.log('[ThemeDataSource] Loading theme from local asset');
      final jsonStr = await rootBundle.loadString('assets/config/theme.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      dev.log('[ThemeDataSource] Loaded theme from asset');
      return Right(ThemeConfigResponseModel().fromJson(data));
    } catch (e) {
      return Left(Exception('Failed to load theme config: $e'));
    }
  }
}

final themeRemoteDataSourceProvider = Provider<ThemeRemoteDataSource>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ThemeRemoteDataSourceImpl(apiHelper);
});
