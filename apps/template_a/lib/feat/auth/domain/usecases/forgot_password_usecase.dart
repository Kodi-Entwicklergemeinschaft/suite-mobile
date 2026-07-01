import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_response_model.dart';
import 'package:template_a/feat/auth/data/repositories/auth_repository_impl.dart';
import 'package:template_a/feat/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Either<Exception, ForgotPasswordResponseModel>> call(ForgotPasswordRequestModel params) async {
    return await _repository.forgotPassword(params);
  }
}

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(repository);
});
