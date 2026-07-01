import 'package:network/network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/interest/data/interest_repo_impl.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/domain/repositories/interest_repo.dart';

final getSelectedInterestUsecaseProvider = Provider<GetSelectedInterestUsecase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return GetSelectedInterestUsecase(repository: repository);
});

class GetSelectedInterestUsecase implements BaseUseCase<SelectedResponseModel, NoParams> {

  final InterestRepo repository;

  GetSelectedInterestUsecase({required this.repository});

  @override
  Future<Either<Exception, SelectedResponseModel>> call(NoParams params) {
    return repository.getSelectedInterest();
  }
}