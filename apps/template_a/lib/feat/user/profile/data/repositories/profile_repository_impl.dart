import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/feat/user/profile/model/response_model/city_languages_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_profile_data_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/get_salutation_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/language_response_model.dart';
import 'package:template_a/feat/user/profile/model/response_model/notification_prefs_response_model.dart';
import 'package:template_a/feat/user/profile/model/request_model/post_profile_data_request_model.dart';
import 'package:template_a/feat/user/profile/domain/repositories/profile_repository.dart';
import 'package:template_a/feat/user/profile/services/profile_service.dart';

import '../../model/request_model/post_profile_data_response_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Future<Either<Exception, GetProfileDataResponseModel>> getProfileData() async {
    final result = await _profileService.getProfileData();
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to load profile'));
      },
    );
  }

  @override
  Future<Either<Exception, PostProfileDataResponseModel>> updateProfileData(
    PostProfileDataRequestModel request, {
    required String userId,
  }) async {
    final result = await _profileService.updateProfileData(request, userId: userId);
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to update profile'));
      },
    );
  }

  @override
  Future<Either<Exception, GetSalutationResponseModel>> getSalutations() async {
    final result = await _profileService.getSalutations();
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to load salutations'));
      },
    );
  }

  @override
  Future<Either<Exception, LanguageResponseModel>> getLanguagePreference() async {
    final result = await _profileService.getLanguagePreference();
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to load language preference'));
      },
    );
  }

  @override
  Future<Either<Exception, LanguageResponseModel>> updateLanguage(
    String language,
  ) async {
    final result = await _profileService.updateLanguage(language);
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to update language'));
      },
    );
  }

  @override
  Future<Either<Exception, LanguageResponseModel>> deleteAccount({String? userId}) async {
    final result = await _profileService.deleteAccount(userId: userId);
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.success == true) return Right(response);
        return Left(Exception(response.message ?? 'Failed to delete account'));
      },
    );
  }

  @override
  Future<Either<Exception, CityLanguagesResponseModel>> getCityLanguages() async {
    final result = await _profileService.getCityLanguages();
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to load city languages'));
      },
    );
  }

  @override
  Future<Either<Exception, NotificationPrefsResponseModel>> getNotificationPrefs() async {
    final result = await _profileService.getNotificationPrefs();
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200) return Right(response);
        return Left(Exception(response.message ?? 'Failed to load notification prefs'));
      },
    );
  }

  @override
  Future<Either<Exception, NotificationPrefsResponseModel>> saveNotificationPrefs({
    required bool notificationsEnabled,
    required bool newsletterSubscribed,
  }) async {
    final result = await _profileService.saveNotificationPrefs(
      notificationsEnabled: notificationsEnabled,
      newsletterSubscribed: newsletterSubscribed,
    );
    return result.fold(
      (error) => Left(error),
      (response) {
        if (response.statusCode == 200 || response.statusCode == 201) return Right(response);
        return Left(Exception(response.message ?? 'Failed to save notification prefs'));
      },
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileRepositoryImpl(profileService);
});