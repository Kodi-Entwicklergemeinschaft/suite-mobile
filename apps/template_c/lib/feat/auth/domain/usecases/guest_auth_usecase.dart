import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/auth/data/models/request_model/guest_auth_request_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/guest_auth_response_model.dart';
import 'package:template_c/feat/auth/domain/repositories/auth_repository.dart';
import 'package:template_c/feat/auth/data/repositories/auth_repository_impl.dart';

/// Provider for guest auth usecase
final guestAuthUseCaseProvider = Provider<GuestAuthUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GuestAuthUseCase(authRepository);
});

/// UseCase for guest authentication
class GuestAuthUseCase
    extends BaseUseCase<GuestAuthResponseModel, GuestAuthRequestModel> {
  final AuthRepository _authRepository;

  GuestAuthUseCase(this._authRepository);

  @override
  Future<Either<Exception, GuestAuthResponseModel>> call(
      GuestAuthRequestModel params) async {
    return await _authRepository.guestAuth(params);
  }
}
