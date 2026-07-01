import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/respnse_model/register_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

/// UseCase for user registration
class RegisterUseCase implements BaseUseCase<RegisterResponseModel, RegisterRequestModel> {
  final AuthRepository repository;

  RegisterUseCase({
    required this.repository,
  });

  @override
  Future<Either<Exception, RegisterResponseModel>> call(RegisterRequestModel params) async {
    final result = await repository.register(params);
    return result.fold((l) => Left(l), (r) => Right(r));
  }
}

/// Provider for RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(
    repository: repository,
  );
});
