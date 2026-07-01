import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_preference_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_preference_response_model.dart';
import 'package:template_c/feat/location_onboarding/data/repo_impl/location_repo_impl.dart';
import 'package:template_c/feat/location_onboarding/domain/repo/location_repo.dart';

final locationPreferenceUseCaseProvider =
    Provider<LocationPreferenceUseCase>((ref) {
  final repo = ref.watch(locationRespoImplProvider);
  return LocationPreferenceUseCase(repo: repo);
});

class LocationPreferenceUseCase
    implements
        BaseUseCase<LocationPreferenceResponseModel,
            LocationPreferenceRequestModel> {
  final LocationRepo repo;

  LocationPreferenceUseCase({required this.repo});

  @override
  Future<Either<Exception, LocationPreferenceResponseModel>> call(
    LocationPreferenceRequestModel params,
  ) {
    return repo.updateLocationPreference(params);
  }
}
