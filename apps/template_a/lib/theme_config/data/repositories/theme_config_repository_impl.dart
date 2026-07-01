import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';
import '../service/theme_config_service.dart';
import '../../domain/repositories/theme_config_repository.dart';

class ThemeConfigRepositoryImpl implements ThemeConfigRepository {
  final ThemeConfigService _service;

  ThemeConfigRepositoryImpl(this._service);

  @override
  Future<Either<Exception, AppTheme>> getThemeConfig() async {
    try {
      final theme = await _service.getThemeConfig();
      return Right(theme);
    } catch (e) {
      return Left(Exception('Failed to load theme config: $e'));
    }
  }
}

final themeConfigRepositoryProvider = Provider<ThemeConfigRepository>((ref) {
  final service = ref.watch(themeConfigServiceProvider);
  return ThemeConfigRepositoryImpl(service);
});
