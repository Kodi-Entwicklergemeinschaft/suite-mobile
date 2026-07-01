import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/response_model/city_languages_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_profile_data_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_salutation_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/notification_prefs_response_model.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_request_model.dart';

import '../../model/request_model/post_profile_data_response_model.dart';

abstract class ProfileRepository {
  Future<Either<Exception, GetProfileDataResponseModel>> getProfileData();

  Future<Either<Exception, PostProfileDataResponseModel>> updateProfileData(
    PostProfileDataRequestModel request, {
    required String userId,
  });

  Future<Either<Exception, GetSalutationResponseModel>> getSalutations();

  Future<Either<Exception, LanguageResponseModel>> getLanguagePreference();

  Future<Either<Exception, LanguageResponseModel>> updateLanguage(
    String language,
  );

  Future<Either<Exception, LanguageResponseModel>> deleteAccount({String? userId});

  Future<Either<Exception, CityLanguagesResponseModel>> getCityLanguages();

  Future<Either<Exception, NotificationPrefsResponseModel>> getNotificationPrefs();

  Future<Either<Exception, NotificationPrefsResponseModel>> saveNotificationPrefs({
    required bool notificationsEnabled,
    required bool newsletterSubscribed,
  });
}