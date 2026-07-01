import 'package:dartz/dartz.dart';
import 'package:network/network.dart';
import 'package:template_b/theme_config/data/repositories/theme_config_repository_impl.dart';
import 'package:theme/theme.dart';
import '../repositories/theme_config_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UseCase provider for getting theme configuration
final getThemeConfigUseCaseProvider = Provider<GetThemeConfigUseCase>((ref) {
  final repository = ref.watch(themeConfigRepositoryProvider);
  return GetThemeConfigUseCase(repository: repository);
});

class GetThemeConfigUseCase implements BaseUseCase<AppTheme, NoParams> {
  final ThemeConfigRepository repository;

  GetThemeConfigUseCase({required this.repository});

  @override
  Future<Either<Exception, AppTheme>> call(NoParams params) async {
    return await repository.getThemeConfig();
  }
}
