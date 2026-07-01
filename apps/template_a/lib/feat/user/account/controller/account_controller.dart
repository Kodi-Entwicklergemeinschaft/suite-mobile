import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localization_controller.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/feat/user/account/state/account_state.dart';

final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(
  () => AccountController(),
);

class AccountController extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  bool get isLoggedIn {
    final prefs = ref.read(preferenceManagerProvider);
    return prefs.getBool(StorageKeys.authIsLoggedIn);
  }

  bool get isGuest {
    final prefs = ref.read(preferenceManagerProvider);
    return prefs.getBool(StorageKeys.authIsGuest);
  }

  bool get isFullyLoggedIn => isLoggedIn && !isGuest;

  Future<void> logout() async {
    state = state.copyWith(isLoggingOut: true);
    final prefs = ref.read(preferenceManagerProvider);
    await prefs.saveBool(StorageKeys.authIsLoggedIn, false);
    await prefs.saveBool(StorageKeys.authIsGuest, false);
    final deviceLang = PlatformDispatcher.instance.locale.languageCode;
    ref.read(localizationControllerProvider.notifier).changeLocale(Locale(deviceLang));
    prefs.saveString('locale', '');
    ref.read(authStateProvider.notifier).setLoggedOut();
    state = state.copyWith(isLoggingOut: false);
  }
}