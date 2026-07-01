import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/api_endpoints.dart';
import 'package:template_a/core/constant/nav_key.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/core/utils/session_expire_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseApiUrl {
  final v = dotenv.maybeGet('BASE_URL') ?? '';
  return (v.isEmpty || v.startsWith('YOUR_')) ? '' : v;
}

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
          headerInterceptor: headerInterceptor,
          onLogout: () async {
            ref.read(authStateProvider.notifier).setLoggedOut();
          },
          onSessionExpired: () async {
            await Future.wait([
              secureStorage.remove(StorageKeys.authAccessToken),
              secureStorage.remove(StorageKeys.authRefreshToken),
              preferences.removePreference(StorageKeys.authExpiresIn),
              preferences.removePreference(StorageKeys.authRole),
              preferences.saveBool(StorageKeys.authIsLoggedIn, false),
              preferences.saveBool(StorageKeys.authIsGuest, false),
            ]);
            ref.read(authStateProvider.notifier).setLoggedOut();
            final ctx = globalNavKey.currentContext;
            if (ctx != null && ctx.mounted) SessionExpireDialog.show(ctx, ref);
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
