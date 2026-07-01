import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';
import 'package:template_c/feat/home/data/repositories/home_repository_impl.dart';
import '../repositories/home_repository.dart';

class GetHomeConfigUseCase implements BaseUseCase<HomeConfigModel, NoParams> {
  final HomeRepository repository;

  GetHomeConfigUseCase({required this.repository});

  @override
  Future<Either<Exception, HomeConfigModel>> call(NoParams params) {
    return repository.getHomeConfig();
  }
}

final getHomeConfigUseCaseProvider = Provider<GetHomeConfigUseCase>((ref) {
  return GetHomeConfigUseCase(
    repository: ref.watch(homeRepositoryProvider),
  );
});
