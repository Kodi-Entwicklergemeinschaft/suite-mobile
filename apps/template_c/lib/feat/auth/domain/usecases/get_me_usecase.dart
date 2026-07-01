import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/auth/data/models/respnse_model/me_response_model.dart';
import 'package:template_c/feat/auth/data/repositories/auth_repository_impl.dart';
import 'package:template_c/feat/auth/domain/repositories/auth_repository.dart';

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository: repository);
});

class GetMeUseCase implements BaseUseCase<MeResponseModel, NoParams> {
  final AuthRepository repository;

  GetMeUseCase({required this.repository});

  @override
  Future<Either<Exception, MeResponseModel>> call(NoParams params) {
    return repository.getMe();
  }
}
