import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/secure_preferences.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/api_endpoints.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/data/models/register_request_model.dart';
import 'package:template_b/feat/auth/data/models/request_model/change_password_request_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/forgot_password_response_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/guest_auth_response_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/guest_register_response_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/login_response_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/register_response_model.dart';
import 'package:template_b/feat/auth/data/models/respnse_model/change_password_response_model.dart';

/// Provider for AuthService
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

/// Service for managing authentication and API calls
class AuthService {
  final ApiHelper _apiHelper;
  final SecurePreferences _secureStorage;
  final AppPreferenceManager _sharedPreferences;

  AuthService({
    required ApiHelper apiHelper,
    required SecurePreferences secureStorage,
    required AppPreferenceManager sharedPreferences,
  }) : _apiHelper = apiHelper,
       _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  /// Register new user
  Future<Either<Exception, RegisterResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    if (!_isLiveMode) {
      return Right(
        RegisterResponseModel(
          success: true,
          message: 'Registration successful.',
        ),
      );
    }
    final result = await _apiHelper.postRequest<RegisterResponseModel>(
      path: ApiEndpoints.authRegister,
      body: request.toJson(),
      create: () => RegisterResponseModel(),
    );
    return result.fold((error) => Left(error), (response) => Right(response));
  }

  /// Login user
  Future<Either<Exception, LoginResponseModel>> login(
    Map<String, dynamic> credentials,
  ) async {
    if (!_isLiveMode) {
      return Right(
        LoginResponseModel(
          accessToken: '',
          refreshToken: '',
          expiresIn: 86400,
          success: true,
          message: 'Login successful.',
        ),
      );
    }
    return await _apiHelper.postRequest<LoginResponseModel>(
      path: ApiEndpoints.authLogin,
      body: credentials,
      create: () => LoginResponseModel(),
    );
  }

  /// Logout user
  Future<Either<Exception, void>> logout() async {
    if (!_isLiveMode) {
      return const Right(null);
    }
    final result = await _apiHelper.postRequest<LoginResponseModel>(
      path: ApiEndpoints.authLogout,
      body: {},
      create: () => LoginResponseModel(),
    );
    return result.fold((error) => Left(error), (_) => const Right(null));
  }

  /// Save authentication tokens and role
  /// Only sets isLoggedIn=true if role is NOT guest (for real users)
  /// For guest users, keeps isLoggedIn=false but saves tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    UserRole? role,
    bool isGuest = true,
  }) async {
    await Future.wait([
      _secureStorage.setString(StorageKeys.authAccessToken, accessToken),
      _secureStorage.setString(StorageKeys.authRefreshToken, refreshToken),
      _sharedPreferences.saveString(
        StorageKeys.authExpiresIn,
        expiresIn.toString(),
      ),
    ]);

    // Save role if provided
    if (role != null) {
      await _sharedPreferences.saveString(StorageKeys.authRole, role.value);
      // Only set isLoggedIn=true for real users (not guests)
      if (role != UserRole.guest) {
        await _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, true);
      }
    }
  }

  /// Update only access token and expiry (for token refresh)
  Future<void> updateAccessToken(String accessToken, int? expiresIn) async {
    await Future.wait([
      _secureStorage.setString(StorageKeys.authAccessToken, accessToken),
      _sharedPreferences.saveString(
        StorageKeys.authExpiresIn,
        (expiresIn ?? 3600).toString(),
      ),
    ]);
  }

  /// Get stored access token from secure storage
  Future<String?> getAccessToken() async {
    return _secureStorage.getString(StorageKeys.authAccessToken);
  }

  /// Get stored refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return _secureStorage.getString(StorageKeys.authRefreshToken);
  }

  /// Get stored token expiration time (in seconds)
  Future<int?> getExpiresIn() async {
    final expiresInStr = _sharedPreferences.getStringOrNull(
      StorageKeys.authExpiresIn,
    );
    return expiresInStr != null ? int.tryParse(expiresInStr) : null;
  }

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // Clear all stored tokens (logout) and mark user as not logged in
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.remove(StorageKeys.authAccessToken),
      _secureStorage.remove(StorageKeys.authRefreshToken),
      _sharedPreferences.removePreference(StorageKeys.authExpiresIn),
      _sharedPreferences.removePreference(StorageKeys.authRole),
      _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, false),
      _sharedPreferences.removePreference(
        StorageKeys.defectReportLastSelectedLocation,
      ),
      LocalitySelectionController.clearAllPersistedData(_sharedPreferences),
    ]);
    await _sharedPreferences.saveBool(StorageKeys.authIsLoggedIn, false);
  }

  /// Request password reset via username
  Future<Either<Exception, ForgotPasswordResponseModel>> forgotPassword(
    Map<String, dynamic> requestBody,
  ) async {
    if (!_isLiveMode) {
      return Right(
        ForgotPasswordResponseModel(
          success: true,
          message: 'Password reset instructions sent.',
        ),
      );
    }
    return await _apiHelper.postRequest<ForgotPasswordResponseModel>(
      path: ApiEndpoints.authPasswordReset,
      body: requestBody,
      create: () => ForgotPasswordResponseModel(),
    );
  }

  /// Check if user is logged in from shared preferences
  Future<bool> isLoggedIn() async {
    return _sharedPreferences.getBool(StorageKeys.authIsLoggedIn);
  }

  /// Authenticate as guest user
  Future<Either<Exception, GuestAuthResponseModel>> guestAuth(
    Map<String, dynamic> requestBody,
  ) async {
    if (!_isLiveMode) {
      return Right(
        GuestAuthResponseModel(
          accessToken: '',
          refreshToken: '',
          expiresIn: 86400,
        ),
      );
    }
    return await _apiHelper.postRequest<GuestAuthResponseModel>(
      path: ApiEndpoints.authGuestLogin,
      body: requestBody,
      create: () => GuestAuthResponseModel(),
    );
  }

  /// Register guest user as permanent user
  Future<Either<Exception, GuestRegisterResponseModel>> guestRegister(
    Map<String, dynamic> requestBody,
  ) async {
    if (!_isLiveMode) {
      return Right(
        GuestRegisterResponseModel(
          success: true,
          message: 'Registration successful.',
        ),
      );
    }
    return await _apiHelper.postRequest<GuestRegisterResponseModel>(
      path: ApiEndpoints.authGuestRegister,
      body: requestBody,
      create: () => GuestRegisterResponseModel(),
    );
  }

  /// Change user password
  Future<Either<Exception, ChangePasswordResponseModel>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    if (!_isLiveMode) {
      return Right(
        ChangePasswordResponseModel(
          success: true,
          message: 'Password changed successfully.',
        ),
      );
    }
    return await _apiHelper.postRequest<ChangePasswordResponseModel>(
      path: ApiEndpoints.authChangePassword,
      body: request.toJson(),
      create: () => ChangePasswordResponseModel(),
    );
  }
}
