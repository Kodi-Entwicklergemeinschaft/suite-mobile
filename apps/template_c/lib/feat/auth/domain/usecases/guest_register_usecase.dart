import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/auth/data/models/request_model/guest_register_request_model.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/guest_register_response_model.dart';
import 'package:template_c/feat/auth/domain/repositories/auth_repository.dart';
import 'package:template_c/feat/auth/data/repositories/auth_repository_impl.dart';

/// Provider for guest register usecase
final guestRegisterUseCaseProvider = Provider<GuestRegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GuestRegisterUseCase(authRepository);
});

/// UseCase for guest user registration
class GuestRegisterUseCase
    extends BaseUseCase<GuestRegisterResponseModel, GuestRegisterRequestModel> {
  final AuthRepository _authRepository;

  GuestRegisterUseCase(this._authRepository);

  @override
  Future<Either<Exception, GuestRegisterResponseModel>> call(
      GuestRegisterRequestModel params) async {
    return await _authRepository.guestRegister(params);
  }
}
