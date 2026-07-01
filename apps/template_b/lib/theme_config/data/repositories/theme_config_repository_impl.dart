import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';
import '../datasources/theme_remote_datasource.dart';
import '../datasources/theme_local_datasource.dart';
import '../../domain/repositories/theme_config_repository.dart';
import '../models/theme_config_response_model.dart';

class ThemeConfigRepositoryImpl implements ThemeConfigRepository {
  final ThemeRemoteDataSource remoteDataSource;
  final ThemeLocalDataSource localDataSource;

  ThemeConfigRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Exception, AppTheme>> getThemeConfig() async {
    final result = await remoteDataSource.fetchThemeConfig();

    return result.fold(
      (error) async {
        // Try cache on error
        final cached = await localDataSource.getCached();
        if (cached != null) return Right(cached);
        return Left(error);
      },
      (response) async {
        final theme = response.data;
        if (theme == null) return Left(Exception('No theme data'));
        // await localDataSource.cache(theme);
        return Right(theme);
      },
    );
  }
}

final themeConfigRepositoryProvider = Provider<ThemeConfigRepository>((ref) {
  return ThemeConfigRepositoryImpl(
    remoteDataSource: ref.watch(themeRemoteDataSourceProvider),
    localDataSource: ref.watch(themeLocalDataSourceProvider),
  );
});
