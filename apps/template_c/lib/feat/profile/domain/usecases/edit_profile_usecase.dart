import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/profile/data/models/edit_profile_request_model.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';
import 'package:template_c/feat/profile/data/repo_impl/profile_repo_impl.dart';
import 'package:template_c/feat/profile/domain/repositories/profile_repository.dart';



/// Parameters for UpdateProfileUseCase
class UpdateProfileParams {
  final EditProfileRequestModel request;
  final String userId;
  UpdateProfileParams({required this.request, required this.userId});
}


/// UseCase to update user profile
class UpdateProfileUseCase implements BaseUseCase<ProfileModel, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  @override
  Future<Either<Exception, ProfileModel>> call(
    UpdateProfileParams params
  ) {
    return repository.updateProfile(params.request, userId: params.userId);
  }
}

/// Provider for UpdateProfileUseCase
final updateProfileUseCaseProvider = Provider((ref) {
  return UpdateProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});
