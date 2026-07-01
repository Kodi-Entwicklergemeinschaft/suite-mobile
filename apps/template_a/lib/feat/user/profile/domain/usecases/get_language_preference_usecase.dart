import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';

class GetLanguagePreferenceUseCase
    implements BaseUseCase<LanguageResponseModel, NoParams> {
  final ProfileRepository repository;

  GetLanguagePreferenceUseCase({required this.repository});

  @override
  Future<Either<Exception, LanguageResponseModel>> call(NoParams params) {
    return repository.getLanguagePreference();
  }
}

final getLanguagePreferenceUseCaseProvider = Provider<GetLanguagePreferenceUseCase>((ref) {
  return GetLanguagePreferenceUseCase(repository: ref.watch(profileRepositoryProvider));
});
