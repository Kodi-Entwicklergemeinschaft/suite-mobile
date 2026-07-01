import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/profile/data/repo_impl/profile_repo_impl.dart';
import 'package:template_c/feat/profile/domain/repositories/profile_repository.dart';

/// UseCase to delete user account
class DeleteAccountUseCase implements BaseUseCase<void, NoParams> {
  final ProfileRepository repository;

  DeleteAccountUseCase({required this.repository});

  @override
  Future<Either<Exception, void>> call(NoParams params, {String? userId}) {
    return repository.deleteAccount(userId: userId);
  }
}

/// Provider for DeleteAccountUseCase
final deleteAccountUseCaseProvider = Provider((ref) {
  return DeleteAccountUseCase(repository: ref.watch(profileRepositoryProvider));
});
