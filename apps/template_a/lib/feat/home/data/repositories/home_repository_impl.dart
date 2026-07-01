import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/home/data/service/home_service.dart';
import 'package:template_a/feat/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _homeService;

  HomeRepositoryImpl(this._homeService);

  @override
  Future<Either<Exception, HomeConfigModel>> getHomeConfig() async {
    try {
      final result = await _homeService.getHomeConfig();
      return result.fold(
        (error) => Left(error),
        (config) => Right(config),
      );
    } catch (e) {
      return Left(Exception('Repository error: $e'));
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final homeService = ref.watch(homeServiceProvider);
  return HomeRepositoryImpl(homeService);
});
