import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/api_endpoints.dart';
import 'package:template_b/core/constants/storage_keys.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/core/utils/session_expire_dialog.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/routes/router_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base API URL — empty string when placeholder/absent so Dio doesn't throw.
String get baseApiUrl {
  final value = dotenv.maybeGet('BASE_URL') ?? '';
  return (value.isEmpty || value.startsWith('YOUR_')) ? '' : value;
}

/// App's API helper provider with auth interceptor
/// Handles all API calls including token refresh internally
final _appApiHelperProvider = Provider<ApiHelper>((ref) {
  final preferences = ref.watch(preferenceManagerProvider);
  final secureStorage = ref.watch(securePreferencesProvider);

  final headerInterceptor = HeaderInterceptor(preferences: preferences);

  return ApiHelper(
    dioHelper: DioHelper(
      baseUrl: baseApiUrl,
      timeoutDuration: const Duration(seconds: 30),
      showLogs: false,
      dioInterceptors: [
        headerInterceptor,
        AuthInterceptor(
          securePreferences: secureStorage,
          baseUrl: baseApiUrl,
          refreshEndpoint: ApiEndpoints.authRefresh,
          headerInterceptor:
              headerInterceptor, // for refresh call may require tenet id and all.
          onLogout: () async {
            ref.read(authStateProvider.notifier).setLoggedOut();
          },
          onSessionExpired: () async {
            final ctx = navigatorKey.currentContext;
            await Future.wait([
              secureStorage.remove(StorageKeys.authAccessToken),
              secureStorage.remove(StorageKeys.authRefreshToken),
              preferences.removePreference(StorageKeys.authExpiresIn),
              preferences.removePreference(StorageKeys.authRole),
              preferences.saveBool(StorageKeys.authIsLoggedIn, false),
              LocalitySelectionController.clearAllPersistedData(preferences),
            ]);
            ref.read(authStateProvider.notifier).setLoggedOut();
            if (ctx != null && ctx.mounted) SessionExpireDialog.show(ctx);
          },
        ),
      ],
    ),
    fallbackErrorMessage: 'An error occurred. Please try again later.',
  );
});

final appProviderOverrides = [
  apiHelperProvider.overrideWith((ref) => ref.watch(_appApiHelperProvider)),
];
