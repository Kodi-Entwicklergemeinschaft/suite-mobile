import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/core/constants/storage_keys.dart';

/// Single source of truth for auth state - watch this to get login status
final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(() => AuthStateNotifier());

/// Notifier for auth state
class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(preferenceManagerProvider);
    return prefs.getBool(StorageKeys.authIsLoggedIn);
  }

  void setLoggedIn() => state = true;
  void setLoggedOut() => state = false;
}
