import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/request_model/login_request_model.dart';
import '../../data/models/respnse_model/login_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

/// UseCase for user login
class LoginUseCase implements BaseUseCase<LoginResponseModel, LoginRequestModel> {
  final AuthRepository repository;

  LoginUseCase({
    required this.repository,
  });

  @override
  Future<Either<Exception, LoginResponseModel>> call(LoginRequestModel params) async {
    final result = await repository.login(params);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}

/// Provider for LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(
    repository: repository,
  );
});
