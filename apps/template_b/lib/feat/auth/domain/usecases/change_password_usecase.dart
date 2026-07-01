import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/auth/data/models/request_model/change_password_request_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/change_password_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

/// UseCase for changing user password
class ChangePasswordUseCase
    implements BaseUseCase<ChangePasswordResponseModel, ChangePasswordRequestModel> {
  final AuthRepository repository;

  ChangePasswordUseCase({required this.repository});

  @override
  Future<Either<Exception, ChangePasswordResponseModel>> call(
    ChangePasswordRequestModel params,
  ) {
    return repository.changePassword(params);
  }
}

/// Provider for ChangePasswordUseCase
final changePasswordUseCaseProvider = Provider((ref) {
  return ChangePasswordUseCase(
    repository: ref.watch(authRepositoryProvider),
  );
});
