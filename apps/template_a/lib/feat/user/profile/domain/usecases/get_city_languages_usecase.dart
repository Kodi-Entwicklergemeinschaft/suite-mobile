import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/response_model/city_languages_response_model.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';

class GetCityLanguagesUseCase
    implements BaseUseCase<CityLanguagesResponseModel, NoParams> {
  final ProfileRepository repository;

  GetCityLanguagesUseCase({required this.repository});

  @override
  Future<Either<Exception, CityLanguagesResponseModel>> call(NoParams params) {
    return repository.getCityLanguages();
  }
}

final getCityLanguagesUseCaseProvider = Provider<GetCityLanguagesUseCase>((ref) {
  return GetCityLanguagesUseCase(repository: ref.watch(profileRepositoryProvider));
});