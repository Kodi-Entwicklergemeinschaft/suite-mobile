import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';
import 'package:template_c/feat/profile/data/repo_impl/profile_repo_impl.dart';
import 'package:template_c/feat/profile/domain/repositories/profile_repository.dart';

/// UseCase to fetch user profile
class GetProfileUseCase implements BaseUseCase<ProfileModel, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  @override
  Future<Either<Exception, ProfileModel>> call(NoParams params) {
    return repository.getProfile();
  }
}

/// Provider for GetProfileUseCase
final getProfileUseCaseProvider = Provider((ref) {
  return GetProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});
