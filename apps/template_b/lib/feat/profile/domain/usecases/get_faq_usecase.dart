import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/profile/data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';
import '../../data/models/faq_model.dart';

/// UseCase to fetch FAQ
class GetFAQUseCase implements BaseUseCase<FAQModel, NoParams> {
  final ProfileRepository repository;

  GetFAQUseCase({required this.repository});

  @override
  Future<Either<Exception, FAQModel>> call(NoParams params) {
    return repository.getFAQ();
  }
}

/// Provider for GetFAQUseCase
final getFAQUseCaseProvider = Provider((ref) {
  return GetFAQUseCase(repository: ref.watch(profileRepositoryProvider));
});
