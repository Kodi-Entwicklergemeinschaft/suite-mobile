import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';
import 'package:template_a/feat/user/profile/model/response_model/notification_prefs_response_model.dart';

class GetNotificationPrefsUseCase
    implements BaseUseCase<NotificationPrefsResponseModel, NoParams> {
  final ProfileRepository repository;

  GetNotificationPrefsUseCase({required this.repository});

  @override
  Future<Either<Exception, NotificationPrefsResponseModel>> call(NoParams params) {
    return repository.getNotificationPrefs();
  }
}

final getNotificationPrefsUseCaseProvider = Provider<GetNotificationPrefsUseCase>((ref) {
  return GetNotificationPrefsUseCase(repository: ref.watch(profileRepositoryProvider));
});
