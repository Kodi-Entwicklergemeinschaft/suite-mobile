import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/repo_impl/location_repo_impl.dart';
import 'package:template_c/feat/location_onboarding/domain/repo/location_repo.dart';

final locationUseCaseProvider = Provider(
  (ref) => LocationUsecase(
    locationRepo: ref.read(locationRespoImplProvider),
  ),
);

class LocationUsecase
    implements BaseUseCase<LocationResponseModel, LocationRequestModel> {
  LocationRepo locationRepo;

  LocationUsecase({required this.locationRepo});

  @override
  Future<Either<Exception, LocationResponseModel>> call(
    LocationRequestModel params,
  ) async {
    final result = await locationRepo.getLocation(params);

    return result.fold((l) => Left(l), (r) => Right(r));
  }
}
