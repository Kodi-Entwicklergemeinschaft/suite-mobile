import 'package:network/network.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/data/models/toggle_onboarded_status_model.dart';
import 'package:template_c/feat/interest/data/models/update_selected_request_model.dart';
import 'package:template_c/feat/interest/domain/repositories/interest_repo.dart';
import 'package:template_c/feat/interest/services/interest_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final interestRepositoryProvider = Provider<InterestRepo>((ref) {
  final interestService = ref.watch(interestServiceProvider);
  return InterestRepoImpl(interestService);
});

class InterestRepoImpl implements InterestRepo {
  final InterestService _interestService;

  InterestRepoImpl(this._interestService);
  @override
  Future<Either<Exception, InterestConfigResponseModel>> getInterestConfig() {
    return _interestService.getInterestConfig();
  }

  @override
  Future<Either<Exception, SelectedResponseModel>> getSelectedInterest() {
    return _interestService.getSelectedInterest();
  }

  @override
  Future<Either<Exception, SelectedResponseModel>> updateSelectedInterest(
    List<String> subcategoryIds,
  ) {
    return _interestService.updateSelectedInterest(
      UpdateSelectedRequestModel(subcategoryIds: subcategoryIds),
    );
  }

  @override
  Future<Either<Exception, ToggleOnboardedStatusResponseModel>> toggleOnboardedStatus(
    bool onboarded,
  ) {
    return _interestService.toggleOnboardedStatus(
      ToggleOnboardedStatusRequestModel(onboarded: onboarded),
    );
  }
}
