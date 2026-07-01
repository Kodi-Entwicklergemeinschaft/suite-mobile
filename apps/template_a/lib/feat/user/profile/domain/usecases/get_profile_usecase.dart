import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_profile_data_response_model.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements BaseUseCase<GetProfileDataResponseModel, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  @override
  Future<Either<Exception, GetProfileDataResponseModel>> call(NoParams params) {
    return repository.getProfileData();
  }
}

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});