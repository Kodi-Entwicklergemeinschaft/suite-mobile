import 'package:network/network.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_preference_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_preference_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';

abstract class LocationRepo {
  Future<Either<Exception, LocationResponseModel>> getLocation(
    LocationRequestModel params,
  );

  Future<Either<Exception, LocationPreferenceResponseModel>>
      updateLocationPreference(LocationPreferenceRequestModel request);
}
