import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/interest/data/interest_repo_impl.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/domain/repositories/interest_repo.dart';

final updateSelectedInterestUsecaseProvider =
    Provider<UpdateSelectedInterestUsecase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return UpdateSelectedInterestUsecase(repository: repository);
});

class UpdateSelectedInterestUsecase
    implements BaseUseCase<SelectedResponseModel, List<String>> {
  final InterestRepo repository;

  UpdateSelectedInterestUsecase({required this.repository});

  @override
  Future<Either<Exception, SelectedResponseModel>> call(List<String> params) {
    return repository.updateSelectedInterest(params);
  }
}
