import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_helper.dart';

/// Abstract provider for API helper (with auth interceptor)
/// Must be overridden in app's ProviderScope
final apiHelperProvider = Provider<ApiHelper>((ref) {
  throw UnimplementedError(
    'apiHelperProvider must be overridden in ProviderScope',
  );
});
