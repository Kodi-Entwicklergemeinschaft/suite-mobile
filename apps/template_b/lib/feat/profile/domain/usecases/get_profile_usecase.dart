import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/profile/data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';

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
