import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:preference_manager/secure_preferences.dart';

/// Interceptor that handles authentication token management.
///
/// Responsibilities:
/// - Adds Bearer token to requests
/// - Refreshes expired tokens automatically
/// - Handles concurrent requests during refresh
/// - Triggers logout on auth failures
///
/// Tokens (access & refresh) are stored securely via [SecurePreferences].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.securePreferences,
    required this.baseUrl,
    required this.refreshEndpoint,
    required this.onLogout,
    required this.onSessionExpired,
    this.tokenExpiryBuffer = const Duration(seconds: 30),
    this.headerInterceptor,
  });

  final SecurePreferences securePreferences;
  final String baseUrl;
  final String refreshEndpoint;
  final Future<void> Function() onLogout;
  final Future<void> Function() onSessionExpired;
  final Duration tokenExpiryBuffer;
  final Interceptor? headerInterceptor;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  Future<String?>? _refreshFuture;
  Dio? _refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _getValidToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        await onSessionExpired();
      } else {
        await onLogout();
      }
      handler.reject(
        e is DioException
            ? e
            : DioException(
                requestOptions: options,
                error: 'Authentication failed: $e',
                type: DioExceptionType.unknown,
              ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    dev.log('[AuthInterceptor] onError: statusCode=$statusCode',
        name: 'AuthInterceptor');

    if (statusCode == 401) {
      await onLogout();
      handler.next(err);
      return;
    }

    // The server returns 403 (not 401) for expired access tokens.
    // Attempt a token refresh and retry the original request once before
    // treating this as a session expiry.
    if (statusCode == 403 && err.requestOptions.extra['auth_retry'] != true) {
      _refreshFuture ??= _performRefresh();
      try {
        final newToken = await _refreshFuture;
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        retryOptions.extra['auth_retry'] = true;
        final response = await _getRefreshDio().fetch(retryOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        dev.log(
            '[AuthInterceptor] Refresh after 403 failed, calling onSessionExpired',
            name: 'AuthInterceptor');
        await onSessionExpired();
      } finally {
        _refreshFuture = null;
      }
    }

    if (statusCode == 304) {
      dev.log('[AuthInterceptor] Calling onSessionExpired for 304',
          name: 'AuthInterceptor');
      await onSessionExpired();
    }

    handler.next(err);
  }

  /// Gets a valid token, refreshing if necessary
  Future<String?> _getValidToken() async {
    final token = await securePreferences.getString(_accessTokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    if (!_isTokenExpiringSoon(token)) {
      return token;
    }

    // Handle concurrent refresh - all callers share the same Future
    _refreshFuture ??= _performRefresh();
    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  /// Performs token refresh via API
  Future<String> _performRefresh() async {
    dev.log('[AuthInterceptor] Starting token refresh...',
        name: 'AuthInterceptor');

    final refreshToken = await securePreferences.getString(_refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      dev.log('[AuthInterceptor] No refresh token available',
          name: 'AuthInterceptor');
      throw Exception('No refresh token available');
    }

    try {
      final dio = _getRefreshDio();

      dev.log('[AuthInterceptor] Refresh request: POST $refreshEndpoint',
          name: 'AuthInterceptor');

      final response = await dio.post(
        refreshEndpoint,
        data: {'refreshToken': refreshToken},
      );

      dev.log('[AuthInterceptor] Refresh response: ${response.statusCode}',
          name: 'AuthInterceptor');

      // Parse and save new tokens
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      final accessToken = responseData['accessToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        dev.log('[AuthInterceptor] ERROR: Response missing accessToken field',
            name: 'AuthInterceptor');
        throw Exception('Token refresh did not provide new access token');
      }

      final newRefreshToken = responseData['refreshToken'] as String?;
      await Future.wait([
        securePreferences.setString(_accessTokenKey, accessToken),
        if (newRefreshToken != null && newRefreshToken.isNotEmpty)
          securePreferences.setString(_refreshTokenKey, newRefreshToken),
      ]);
      dev.log('[AuthInterceptor] Token refresh successful',
          name: 'AuthInterceptor');

      return accessToken;
    } on DioException catch (e) {
      dev.log(
          '[AuthInterceptor] Refresh failed: '
          '${e.response?.statusCode} ${e.response?.data}',
          name: 'AuthInterceptor');
      rethrow;
    } catch (e) {
      dev.log('[AuthInterceptor] Unexpected error during refresh: $e',
          name: 'AuthInterceptor', error: e);
      rethrow;
    }
  }

  /// Gets or creates dedicated Dio instance for refresh calls
  Dio _getRefreshDio() {
    if (_refreshDio != null) return _refreshDio!;

    _refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (headerInterceptor != null) {
      _refreshDio!.interceptors.add(headerInterceptor!);
    }
    
   return _refreshDio!;
  }

  /// Checks if token is expired or expiring soon
  bool _isTokenExpiringSoon(String token) {
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      final bufferTime = DateTime.now().add(tokenExpiryBuffer);
      final isExpiring = expiryDate.isBefore(bufferTime);
      if (isExpiring) {
        final isExpired = expiryDate.isBefore(DateTime.now());
        dev.log(
          '[AuthInterceptor] Token ${isExpired ? 'expired' : 'expiring soon'}, needs refresh',
          name: 'AuthInterceptor',
        );
      }
      return isExpiring;
    } catch (e) {
      dev.log('[AuthInterceptor] Invalid token, needs refresh',
          name: 'AuthInterceptor');
      return true;
    }
  }
}
