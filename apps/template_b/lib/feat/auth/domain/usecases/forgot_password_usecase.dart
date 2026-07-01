import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/request_model/forgot_password_request_model.dart';
import '../../data/models/respnse_model/forgot_password_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Provider for forgot password usecase
final forgotPasswordUseCaseProvider =
    Provider<ForgotPasswordUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(authRepository);
});

/// Usecase for requesting password reset
class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  /// Request password reset with username
  Future<Either<Exception, ForgotPasswordResponseModel>> call(
    ForgotPasswordRequestModel request,
  ) async {
    return await _authRepository.forgotPassword(request);
  }
}
