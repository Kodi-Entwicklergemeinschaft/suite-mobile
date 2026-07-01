import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';

class UpdateLanguageParams {
  final String language;
  const UpdateLanguageParams(this.language);
}

class UpdateLanguageUseCase
    implements BaseUseCase<LanguageResponseModel, UpdateLanguageParams> {
  final ProfileRepository repository;

  UpdateLanguageUseCase({required this.repository});

  @override
  Future<Either<Exception, LanguageResponseModel>> call(
    UpdateLanguageParams params,
  ) {
    return repository.updateLanguage(params.language);
  }
}

final updateLanguageUseCaseProvider = Provider<UpdateLanguageUseCase>((ref) {
  return UpdateLanguageUseCase(repository: ref.watch(profileRepositoryProvider));
});