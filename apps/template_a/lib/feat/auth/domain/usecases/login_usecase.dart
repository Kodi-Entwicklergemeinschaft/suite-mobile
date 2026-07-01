import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/auth/data/models/login_request_model.dart';
import 'package:template_a/feat/auth/data/models/login_response_model.dart';
import 'package:template_a/feat/auth/data/repositories/auth_repository_impl.dart';
import 'package:template_a/feat/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Exception, LoginResponseModel>> call(LoginRequestModel params) async {
    return await _repository.login(params);
  }
}

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});
