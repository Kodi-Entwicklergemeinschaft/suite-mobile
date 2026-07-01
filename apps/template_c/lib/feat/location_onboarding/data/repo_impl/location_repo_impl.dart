import 'package:dartz/dartz.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_preference_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_preference_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/service/location_service.dart';
import 'package:template_c/feat/location_onboarding/domain/repo/location_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationRespoImplProvider = Provider(
  (ref) => LocationRepoImpl(locationService: ref.read(locationServiceProvider)),
);

class LocationRepoImpl implements LocationRepo {
  LocationService locationService;

  LocationRepoImpl({required this.locationService});

  @override
  Future<Either<Exception, LocationResponseModel>> getLocation(
    LocationRequestModel params,
  ) async {
    final result = await locationService.getLocation(params);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  @override
  Future<Either<Exception, LocationPreferenceResponseModel>>
      updateLocationPreference(LocationPreferenceRequestModel request) {
    return locationService.updateLocationPreference(request);
  }
}
