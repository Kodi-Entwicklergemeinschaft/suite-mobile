import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';
import 'package:template_b/feat/home/data/models/get_localities_filter_model.dart';
import 'package:template_b/feat/home/data/repositories/home_repository_impl.dart';
import '../repositories/home_repository.dart';

class GetLocalitiesParams {
  final GetLocalitiesFilterModel filter;

  GetLocalitiesParams({required this.filter});
}

class GetLocalitiesUseCase
    implements BaseUseCase<LocalityListResponse, GetLocalitiesParams> {
  final HomeRepository _repository;

  GetLocalitiesUseCase({required HomeRepository repository}) : _repository = repository;

  @override
  Future<Either<Exception, LocalityListResponse>> call(
    GetLocalitiesParams params,
  ) {
    return _repository.getLocalities(params.filter);
  }
}

final getLocalitiesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetLocalitiesUseCase(repository: repository);
});
