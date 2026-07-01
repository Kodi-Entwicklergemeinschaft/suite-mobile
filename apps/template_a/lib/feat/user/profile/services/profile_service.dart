import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_request_model.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_profile_data_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_salutation_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/city_languages_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/notification_prefs_response_model.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ProfileService(apiHelper: apiHelper);
});

class ProfileService {
  final ApiHelper _apiHelper;

  ProfileService({required ApiHelper apiHelper}) : _apiHelper = apiHelper;

  Future<Either<Exception, GetProfileDataResponseModel>> getProfileData() async {
    if (!isLiveMode) {
      return Right(GetProfileDataResponseModel().fromJson({
        'success': true,
        'data': {
          'id': 'offline-user-id',
          'email': 'demo@example.com',
          'username': 'demo_user',
          'role': 'user',
          'firstName': 'Demo',
          'lastName': 'User',
          'salutationCode': null,
          'hasVehicle': false,
          'profilePhotoUrl': null,
          'preferredLanguage': 'de',
          'status': 'active',
        },
        'message': 'Profile loaded.',
        'statusCode': 200,
      }));
    }
    try {
      dev.log('[ProfileService] Fetching profile data');
      final result = await _apiHelper.getRequest<GetProfileDataResponseModel>(
        path: ApiEndpoints.profileGet,
        create: () => GetProfileDataResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error fetching profile: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to fetch profile: $e'));
    }
  }

  Future<Either<Exception, PostProfileDataResponseModel>> updateProfileData(
    PostProfileDataRequestModel request, {
    required String userId,
  }) async {
    if (!isLiveMode) {
      return Right(PostProfileDataResponseModel().fromJson({'success': true, 'message': 'Profile updated.'}));
    }
    try {
      dev.log('[ProfileService] Updating profile data');
      final result = await _apiHelper.putRequest<PostProfileDataResponseModel>(
        path: '${ApiEndpoints.profileBase}/$userId',
        body: request.toJson(),
        create: () => PostProfileDataResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error updating profile: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to update profile: $e'));
    }
  }

  Future<Either<Exception, GetSalutationResponseModel>> getSalutations() async {
    if (!isLiveMode) {
      return Right(GetSalutationResponseModel().fromJson({
        'success': true,
        'data': [
          {'code': 'mr', 'label': 'Mr.'},
          {'code': 'ms', 'label': 'Ms.'},
          {'code': 'mx', 'label': 'Mx.'},
        ],
        'statusCode': 200,
      }));
    }
    try {
      dev.log('[ProfileService] Fetching salutations');
      final result = await _apiHelper.getRequest<GetSalutationResponseModel>(
        path: ApiEndpoints.salutations,
        create: () => GetSalutationResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error fetching salutations: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to fetch salutations: $e'));
    }
  }

  Future<Either<Exception, LanguageResponseModel>> getLanguagePreference() async {
    if (!isLiveMode) {
      return Right(LanguageResponseModel().fromJson({'success': true, 'data': {'preferredLanguage': 'de'}}));
    }
    try {
      dev.log('[ProfileService] Fetching language preference');
      final result = await _apiHelper.getRequest<LanguageResponseModel>(
        path: ApiEndpoints.mePreferences,
        create: () => LanguageResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error fetching language preference: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to fetch language preference: $e'));
    }
  }

  Future<Either<Exception, LanguageResponseModel>> updateLanguage(
    String language,
  ) async {
    if (!isLiveMode) {
      return Right(LanguageResponseModel().fromJson({'success': true}));
    }
    try {
      dev.log('[ProfileService] Updating language to $language');
      final result = await _apiHelper.patchRequest<LanguageResponseModel>(
        path: ApiEndpoints.mePreferences,
        body: {'preferredLanguage': language},
        create: () => LanguageResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error updating language: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to update language: $e'));
    }
  }

  Future<Either<Exception, CityLanguagesResponseModel>> getCityLanguages() async {
    if (!isLiveMode) {
      return Right(CityLanguagesResponseModel().fromJson({
        'success': true,
        'data': {
          'defaultLanguage': 'en',
          'enabledLanguages': ['en', 'de'],
        },
        'statusCode': 200,
      }));
    }
    try {
      dev.log('[ProfileService] Fetching city languages');
      final result = await _apiHelper.getRequest<CityLanguagesResponseModel>(
        path: ApiEndpoints.cityLanguages,
        create: () => CityLanguagesResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error fetching city languages: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to fetch city languages: $e'));
    }
  }

  Future<Either<Exception, NotificationPrefsResponseModel>> getNotificationPrefs() async {
    if (!isLiveMode) {
      return Right(NotificationPrefsResponseModel().fromJson({'success': true, 'data': {}}));
    }
    try {
      dev.log('[ProfileService] Fetching notification prefs');
      final result = await _apiHelper.getRequest<NotificationPrefsResponseModel>(
        path: ApiEndpoints.mePreferences,
        create: () => NotificationPrefsResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error fetching notification prefs: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to fetch notification prefs: $e'));
    }
  }

  Future<Either<Exception, NotificationPrefsResponseModel>> saveNotificationPrefs({
    required bool notificationsEnabled,
    required bool newsletterSubscribed,
  }) async {
    if (!isLiveMode) {
      return Right(NotificationPrefsResponseModel().fromJson({'success': true}));
    }
    try {
      dev.log('[ProfileService] Saving notification prefs');
      final result = await _apiHelper.patchRequest<NotificationPrefsResponseModel>(
        path: ApiEndpoints.mePreferences,
        body: {
          'notificationsEnabled': notificationsEnabled,
          'newsletterSubscribed': newsletterSubscribed,
        },
        create: () => NotificationPrefsResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error saving notification prefs: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to save notification prefs: $e'));
    }
  }

  Future<Either<Exception, LanguageResponseModel>> deleteAccount({String? userId}) async {
    if (!isLiveMode) {
      return Right(LanguageResponseModel().fromJson({'success': true}));
    }
    if (userId == null || userId.isEmpty) {
      return Left(Exception('User ID not found. Please re-login.'));
    }
    try {
      dev.log('[ProfileService] Deleting account for userId: $userId');
      final result = await _apiHelper.deleteRequest<LanguageResponseModel>(
        path: '${ApiEndpoints.profileBase}/$userId',
        create: () => LanguageResponseModel(),
      );
      return result.fold((error) => Left(error), (response) => Right(response));
    } catch (e, stackTrace) {
      dev.log('[ProfileService] Error deleting account: $e', stackTrace: stackTrace);
      return Left(Exception('Failed to delete account: $e'));
    }
  }
}