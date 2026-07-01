import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// UseCase for user logout
class LogoutUseCase implements BaseUseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  @override
  Future<Either<Exception, void>> call(NoParams params) async {
    final result = await repository.logout();
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}

/// Provider for LogoutUseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository: repository);
});
