import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/api_endpoints.dart';
import 'package:template_c/core/providers/auth_state_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base API URL — empty string in open-source mode (YOUR_BASE_URL placeholder)
String get baseApiUrl {
  final value = dotenv.env['BASE_URL'] ?? '';
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
          }, onSessionExpired: ()async {  },
        ),
      ],
    ),
    fallbackErrorMessage: 'An error occurred. Please try again later.',
  );
});

final appProviderOverrides = [
  apiHelperProvider.overrideWith((ref) => ref.watch(_appApiHelperProvider)),
];
