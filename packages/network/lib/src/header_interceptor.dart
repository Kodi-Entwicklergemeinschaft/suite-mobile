import 'package:dio/dio.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor({
    required this.preferences,
    this.localeKey = 'locale',
  });

  final PreferenceManager preferences;
  final String localeKey;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Required headers
    final isFormData = options.data is FormData;

    if (!isFormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    options.headers['Accept'] = 'application/json';

    // Optional: locale from storage
    final locale = preferences.getStringOrNull(localeKey);
    if (locale != null && locale.isNotEmpty) {
      options.headers['Accept-Language'] = locale;
    }

    options.headers['X-Tenant-ID'] = dotenv.env['TENANT_ID'];
    options.headers['X-Api-Key'] = dotenv.env['X-Api-Key'];

    super.onRequest(options, handler);
  }
}
