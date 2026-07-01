import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_model.dart';
import 'package:template_b/feat/home/data/models/update_locality_selection_response_model.dart';
import 'package:template_b/feat/home/data/repositories/home_repository_impl.dart';
import '../repositories/home_repository.dart';

class ToggleLocalityParams {
  final List<String> localityIds;

  ToggleLocalityParams({required this.localityIds});
}

class ToggleLocalityUseCase
    implements BaseUseCase<UpdateLocalitySelectionResponseModel, ToggleLocalityParams> {
  final HomeRepository _repository;

  ToggleLocalityUseCase({required HomeRepository repository}) : _repository = repository;

  @override
  Future<Either<Exception, UpdateLocalitySelectionResponseModel>> call(
    ToggleLocalityParams params,
  ) {
    final model = UpdateLocalitySelectionModel(localities: params.localityIds);
    return _repository.updateLocalitySelection(model);
  }
}

final toggleLocalityUseCaseProvider = Provider((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return ToggleLocalityUseCase(repository: repository);
});
