import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase({required this.repository});

  Future<Either<Exception, LanguageResponseModel>> call({String? userId}) {
    return repository.deleteAccount(userId: userId);
  }
}

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(repository: ref.watch(profileRepositoryProvider));
});