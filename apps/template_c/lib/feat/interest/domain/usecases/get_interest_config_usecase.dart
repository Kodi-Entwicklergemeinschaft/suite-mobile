import 'package:network/network.dart';
import 'package:template_c/feat/interest/data/interest_repo_impl.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/interest/domain/repositories/interest_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getInterestConfigUsecaseProvider = Provider<GetInterestConfigUsecase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return GetInterestConfigUsecase(repository: repository);
});

class GetInterestConfigUsecase implements BaseUseCase<InterestConfigResponseModel, NoParams> {

  final InterestRepo repository;

  GetInterestConfigUsecase({required this.repository});

  @override
  Future<Either<Exception, InterestConfigResponseModel>> call(NoParams params) {
    return repository.getInterestConfig();
  }
}