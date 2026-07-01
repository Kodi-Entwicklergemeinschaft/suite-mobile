import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';
import 'package:template_a/feat/user/profile/model/response_model/notification_prefs_response_model.dart';

class SaveNotificationPrefsParams {
  final bool notificationsEnabled;
  final bool newsletterSubscribed;

  const SaveNotificationPrefsParams({
    required this.notificationsEnabled,
    required this.newsletterSubscribed,
  });
}

class SaveNotificationPrefsUseCase
    implements BaseUseCase<NotificationPrefsResponseModel, SaveNotificationPrefsParams> {
  final ProfileRepository repository;

  SaveNotificationPrefsUseCase({required this.repository});

  @override
  Future<Either<Exception, NotificationPrefsResponseModel>> call(
    SaveNotificationPrefsParams params,
  ) {
    return repository.saveNotificationPrefs(
      notificationsEnabled: params.notificationsEnabled,
      newsletterSubscribed: params.newsletterSubscribed,
    );
  }
}

final saveNotificationPrefsUseCaseProvider = Provider<SaveNotificationPrefsUseCase>((ref) {
  return SaveNotificationPrefsUseCase(repository: ref.watch(profileRepositoryProvider));
});
