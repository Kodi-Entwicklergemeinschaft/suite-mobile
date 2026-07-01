import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/auth/data/models/login_response_model.dart';
import 'package:template_a/feat/auth/data/repositories/auth_repository_impl.dart';
import 'package:template_a/feat/auth/domain/repositories/auth_repository.dart';

class GuestLoginUseCase {
  final AuthRepository _repository;

  GuestLoginUseCase(this._repository);

  Future<Either<Exception, LoginResponseModel>> call({
    required String deviceId,
  }) async {
    return await _repository.guestLogin(deviceId: deviceId);
  }
}

final guestLoginUseCaseProvider = Provider<GuestLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GuestLoginUseCase(repository);
});
