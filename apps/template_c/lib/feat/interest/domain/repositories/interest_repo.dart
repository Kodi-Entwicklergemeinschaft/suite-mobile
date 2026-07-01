import 'package:network/network.dart';
import 'package:template_c/feat/interest/data/models/interest_config_response_model.dart';
import 'package:template_c/feat/interest/data/models/selected_response_model.dart';
import 'package:template_c/feat/interest/data/models/toggle_onboarded_status_model.dart';

abstract class InterestRepo {
  Future<Either<Exception, InterestConfigResponseModel>> getInterestConfig();

  Future<Either<Exception, SelectedResponseModel>> getSelectedInterest();

  Future<Either<Exception, SelectedResponseModel>> updateSelectedInterest(
    List<String> subcategoryIds,
  );

  Future<Either<Exception, ToggleOnboardedStatusResponseModel>> toggleOnboardedStatus(
    bool onboarded,
  );

}
