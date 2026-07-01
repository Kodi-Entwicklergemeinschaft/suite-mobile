import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_request_model.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';

import '../../model/request_model/post_profile_data_response_model.dart';

class UpdateProfileParams {
  final PostProfileDataRequestModel request;
  final String userId;
  const UpdateProfileParams({required this.request, required this.userId});
}

class UpdateProfileUseCase
    implements BaseUseCase<PostProfileDataResponseModel, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  @override
  Future<Either<Exception, PostProfileDataResponseModel>> call(
    UpdateProfileParams params,
  ) {
    return repository.updateProfileData(params.request, userId: params.userId);
  }
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});