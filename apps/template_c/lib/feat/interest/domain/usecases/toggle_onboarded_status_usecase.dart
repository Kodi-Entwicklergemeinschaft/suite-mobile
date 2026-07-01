import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/interest/data/interest_repo_impl.dart';
import 'package:template_c/feat/interest/data/models/toggle_onboarded_status_model.dart';
import 'package:template_c/feat/interest/domain/repositories/interest_repo.dart';

final toggleOnboardedStatusUsecaseProvider =
    Provider<ToggleOnboardedStatusUsecase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return ToggleOnboardedStatusUsecase(repository: repository);
});

class ToggleOnboardedStatusUsecase
    implements BaseUseCase<ToggleOnboardedStatusResponseModel, bool> {
  final InterestRepo repository;

  ToggleOnboardedStatusUsecase({required this.repository});

  @override
  Future<Either<Exception, ToggleOnboardedStatusResponseModel>> call(bool params) {
    return repository.toggleOnboardedStatus(params);
  }
}
