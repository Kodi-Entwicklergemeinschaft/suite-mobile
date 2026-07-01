import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/auth/data/models/register_request_model.dart';
import 'package:template_a/feat/auth/data/models/register_response_model.dart';
import 'package:template_a/feat/auth/data/repositories/auth_repository_impl.dart';
import 'package:template_a/feat/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Exception, RegisterResponseModel>> call(RegisterRequestModel params) async {
    return await _repository.register(params);
  }
}

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});
