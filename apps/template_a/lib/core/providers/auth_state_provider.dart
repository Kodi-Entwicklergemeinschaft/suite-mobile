import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(() => AuthStateNotifier());

class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(preferenceManagerProvider);
    return prefs.getBool(StorageKeys.authIsLoggedIn);
  }

  void setLoggedIn() => state = true;
  void setLoggedOut() => state = false;
}
