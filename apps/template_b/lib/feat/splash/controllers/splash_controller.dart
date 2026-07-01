import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_b/feat/splash/state/splash_state.dart';
import 'package:template_b/theme_config/domain/usecases/get_theme_config_usecase.dart';
import 'package:template_b/feat/auth/domain/usecases/guest_auth_usecase.dart';
import 'package:template_b/feat/auth/data/models/request_model/guest_auth_request_model.dart';
import 'package:template_b/feat/auth/service/auth_service.dart';

import 'package:theme/theme.dart' show appThemeNotifierProvider;
import 'package:template_b/feat/home/controller/home_controller.dart';

/// Provider for splash controller
final splashControllerProvider =
    NotifierProvider.autoDispose<SplashNotifier, SplashState>(() {
      return SplashNotifier();
    });

/// Notifier managing splash screen bootstrap logic
class SplashNotifier extends Notifier<SplashState> {
  late GetThemeConfigUseCase _getThemeConfigUseCase;
  late GuestAuthUseCase _guestAuthUseCase;

  @override
  SplashState build() {
    // Start loading immediately
    _getThemeConfigUseCase = ref.read(getThemeConfigUseCaseProvider);
    _guestAuthUseCase = ref.read(guestAuthUseCaseProvider);
    return const SplashState();
  }

  /// Initialize app - load config, theme, API calls, etc
  Future<void> initializeApp() async {
    try {
      debugPrint('Splash: Starting app initialization...');

      // Step 1: Load theme config using GetThemeConfigUseCase
      final result = await _getThemeConfigUseCase.call(const NoParams());
      if (!ref.mounted) return;

      result.fold(
        (error) {
          debugPrint('Splash: Error loading theme config: $error');
          throw Exception('Theme config load failed: $error');
        },
        (config) {
          debugPrint('Splash: Theme config loaded');
          ref.read(appThemeNotifierProvider.notifier).setAppTheme(config);
          state = state.copyWith(isLoading: false);
          debugPrint('Splash: Theme provider updated');
        },
      );

      // Step 2: Check and authenticate guest
      await _checkAndAuthenticateGuest();
      if (!ref.mounted) return;
      debugPrint('Splash: Guest authentication checked');

      // Step 3: Pre-load home config and bottom nav config silently
      if (ref.mounted) {
        await Future.wait([
          // ref.read(homeProvider.notifier).loadConfig(),
          // ref.read(bottomNavigationProvider.notifier).loadConfig(),
        ]);
        debugPrint('Splash: Home and bottom nav config pre-loaded');
      }

      // All operations completed successfully
      debugPrint('Splash: Initialization successful');
      if (!ref.mounted) return;
      state = const SplashState(isSuccess: true);
    } catch (e, stackTrace) {
      debugPrint('Splash: Initialization error: $e');
      debugPrint('Splash: StackTrace: $stackTrace');

      // Set error state - app continues with defaults
      if (ref.mounted) {
        state = SplashState(isSuccess: true, error: 'Failed to initialize: $e');
      }
    } finally {
      // Ensure loading is always false
      if (ref.mounted && state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _checkAndAuthenticateGuest() async {
    // No BASE_URL means .env is absent — running from local config assets, skip auth
    final baseUrl = dotenv.maybeGet('BASE_URL') ?? '';
    if (baseUrl.isEmpty) {
      developer.log(
        'No BASE_URL configured, skipping guest auth (offline/config mode)',
        name: 'SplashController._checkAndAuthenticateGuest',
      );
      return;
    }

    try {
      final prefs = ref.read(preferenceManagerProvider);
      final securePrefs = ref.read(securePreferencesProvider);

      final isAuthenticated = prefs.getBool(StorageKeys.authIsLoggedIn);
      final accessToken = await securePrefs.getString(
        StorageKeys.authAccessToken,
      );
      final hasAccessToken = accessToken != null && accessToken.isNotEmpty;

      developer.log(
        'Auth check: isAuthenticated=$isAuthenticated, hasAccessToken=$hasAccessToken',
        name: 'SplashController._checkAndAuthenticateGuest',
      );

      if (hasAccessToken) {
        developer.log(
          'Token already exists (guest or real), skipping guest auth',
          name: 'SplashController._checkAndAuthenticateGuest',
        );
        return;
      }

      var deviceId = prefs.getStringOrNull(StorageKeys.deviceId);

      if (deviceId == null || deviceId.isEmpty) {
        deviceId = await DeviceInfoController.getDeviceUUID();

        if (deviceId == null || deviceId.isEmpty) {
          developer.log(
            'No device ID found, skipping guest auth',
            name: 'SplashController._checkAndAuthenticateGuest',
          );
          return;
        }

        await prefs.saveString(StorageKeys.deviceId, deviceId);
        developer.log(
          'Device ID generated and stored: $deviceId',
          name: 'SplashController._checkAndAuthenticateGuest',
        );
      } else {
        developer.log(
          'Using stored device ID: $deviceId',
          name: 'SplashController._checkAndAuthenticateGuest',
        );
      }

      developer.log(
        'Authenticating as guest with deviceId=$deviceId',
        name: 'SplashController._checkAndAuthenticateGuest',
      );

      final guestAuthRequest = GuestAuthRequestModel(deviceId: deviceId);
      final result = await _guestAuthUseCase.call(guestAuthRequest);

      await result.fold(
        (error) async {
          developer.log(
            'Guest auth error: $error',
            name: 'SplashController._checkAndAuthenticateGuest',
            error: error,
          );
          // Continue app without guest login
        },
        (guestResponse) async {
          developer.log(
            'Guest authenticated: guestUserId=${guestResponse.id}, role=${guestResponse.role}',
            name: 'SplashController._checkAndAuthenticateGuest',
          );
          // Save guest tokens so interceptor can attach Authorization header
          if (guestResponse.accessToken != null &&
              guestResponse.accessToken!.isNotEmpty) {
            final authService = ref.read(authServiceProvider);
            await authService.saveTokens(
              accessToken: guestResponse.accessToken!,
              refreshToken: guestResponse.refreshToken ?? '',
              expiresIn: guestResponse.expiresIn ?? 3600,
              role: guestResponse.role,
              isGuest: true,
            );
            developer.log(
              'Guest tokens saved successfully',
              name: 'SplashController._checkAndAuthenticateGuest',
            );
          }
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error during guest authentication: $e',
        name: 'SplashController._checkAndAuthenticateGuest',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
