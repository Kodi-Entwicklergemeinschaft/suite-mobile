import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/secure_preferences.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_request_model.dart';
import 'package:template_a/feat/auth/data/models/forgot_password_response_model.dart';
import 'package:template_a/feat/auth/data/models/login_request_model.dart';
import 'package:template_a/feat/auth/data/models/login_response_model.dart';
import 'package:template_a/feat/auth/data/models/register_request_model.dart';
import 'package:template_a/feat/auth/data/models/register_response_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  final secureStorage = ref.watch(securePreferencesProvider);
  final sharedPreferences = ref.watch(preferenceManagerProvider);
  return AuthService(
    apiHelper: apiHelper,
    secureStorage: secureStorage,
    sharedPreferences: sharedPreferences,
  );
});

class AuthService {
  final ApiHelper _apiHelper;
  final SecurePreferences _secureStorage;
  final AppPreferenceManager _sharedPreferences;

  AuthService({
    required ApiHelper apiHelper,
    required SecurePreferences secureStorage,
    required AppPreferenceManager sharedPreferences,
  })  : _apiHelper = apiHelper,
        _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  Future<Either<Exception, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    if (!isLiveMode) {
      return Right(LoginResponseModel().fromJson({
        'accessToken': '',
        'refreshToken': '',
        'expiresIn': 86400,
        'success': true,
        'message': 'Login successful.',
      }));
    }
    try {
      final dynamic res = await _apiHelper.dio.post(ApiEndpoints.authLogin, data: request.toJson());
      return Right(LoginResponseModel().fromJson(res.data ?? {}));
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }

  Future<Either<Exception, LoginResponseModel>> guestLogin({
    required String deviceId,
  }) async {
    if (!isLiveMode) {
      return Right(LoginResponseModel().fromJson({
        'accessToken': '',
        'refreshToken': '',
        'expiresIn': 86400,
        'success': true,
        'message': 'Guest login successful.',
      }));
    }
    try {
      final dynamic res = await _apiHelper.dio.post(ApiEndpoints.authGuestLogin, data: {'deviceId': deviceId});
      return Right(LoginResponseModel().fromJson(res.data ?? {}));
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }

  Future<Either<Exception, RegisterResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    if (!isLiveMode) {
      return Right(RegisterResponseModel().fromJson({
        'success': true,
        'message': 'Registration successful.',
      }));
    }
    try {
      final dynamic res = await _apiHelper.dio.post(ApiEndpoints.authRegister, data: request.toJson());
      return Right(RegisterResponseModel().fromJson(res.data ?? {}));
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }

  Future<Either<Exception, ForgotPasswordResponseModel>> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    if (!isLiveMode) {
      return Right(ForgotPasswordResponseModel().fromJson({
        'success': true,
        'message': 'Password reset email sent.',
      }));
    }
    try {
      final dynamic res = await _apiHelper.dio.post(ApiEndpoints.authPasswordReset, data: request.toJson());
      return Right(ForgotPasswordResponseModel().fromJson(res.data ?? {}));
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    await Future.wait([
      _secureStorage.setString(StorageKeys.authAccessToken, accessToken),
      _secureStorage.setString(StorageKeys.authRefreshToken, refreshToken),
      _sharedPreferences.saveString(
        StorageKeys.authExpiresIn,
        expiresIn.toString(),
      ),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.remove(StorageKeys.authAccessToken),
      _secureStorage.remove(StorageKeys.authRefreshToken),
      _sharedPreferences.removePreference(StorageKeys.authExpiresIn),
    ]);
    await _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, false);
  }

  Future<void> setLoggedIn() async {
    await _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, true);
  }

  Future<void> setGuestUser() async {
    await _sharedPreferences.saveBool(StorageKeys.authIsGuest, true);
  }

  Future<Either<Exception, void>> toggleOnboardedStatus(bool onboarded) async {
    if (!isLiveMode) {
      return const Right(null);
    }
    try {
      await _apiHelper.dio.put(
        ApiEndpoints.toggleOnboardedStatus,
        data: {'onboarded': onboarded},
      );
      return const Right(null);
    } catch (e) {
      return Left(ApiError(error: e.toString()));
    }
  }
}
