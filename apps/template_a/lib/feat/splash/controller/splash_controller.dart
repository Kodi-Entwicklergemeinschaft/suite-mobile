import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localization_controller.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/utils/config_mode.dart';
import 'package:template_a/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_a/feat/splash/controller/splash_state.dart';
import 'package:template_a/feat/user/profile/domain/usecases/get_language_preference_usecase.dart';
import 'package:template_a/feat/user/profile/domain/usecases/update_language_usecase.dart';
import 'package:theme/theme.dart';

import '../../../theme_config/domain/usecases/get_theme_config_usecase.dart';

final splashControllerProvider =
    NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);

class SplashNotifier extends Notifier<SplashState> {
  late GetThemeConfigUseCase _getThemeConfigUseCase;
  late GetLanguagePreferenceUseCase _getLanguagePreferenceUseCase;
  late UpdateLanguageUseCase _updateLanguageUseCase;
  bool _initialized = false;

  @override
  SplashState build() {
    _getThemeConfigUseCase = ref.read(getThemeConfigUseCaseProvider);
    _getLanguagePreferenceUseCase = ref.read(getLanguagePreferenceUseCaseProvider);
    _updateLanguageUseCase = ref.read(updateLanguageUseCaseProvider);
    return const SplashState();
  }

  Future<void> initializeApp() async {
    if (_initialized) return;
    _initialized = true;
    final themeLoaded = await _loadThemeConfig();
    if (!ref.mounted) return;

    if (!themeLoaded) return;

    await _initializeLanguagePreference();
    if (!ref.mounted) return;
    await ref.read(bottomNavigationProvider.notifier).loadConfig();
    if (!ref.mounted) return;

    await Future.delayed(const Duration(seconds: 3));
    if (ref.mounted) {
      state = state.copyWith(isThemeLoaded: true);
    }
  }

  Future<void> _initializeLanguagePreference() async {
    if (!isLiveMode) return;

    final prefManager = ref.read(preferenceManagerProvider);
    final isLoggedIn = prefManager.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefManager.getBool(StorageKeys.authIsGuest);

    if (!isLoggedIn && !isGuest) return; // unauthenticated: device lang is fine

    // Always fetch from backend so we never drift from the user's stored preference
    final result = await _getLanguagePreferenceUseCase.call(const NoParams());
    if (!ref.mounted) return;

    result.fold(
      (_) {}, // API failure: silently skip, device lang stays
      (langResponse) {
        final preferred = langResponse.data?.preferredLanguage;
        final currentLang = ref.read(localizationControllerProvider).languageCode;

        if (preferred != null && preferred.isNotEmpty) {
          if (preferred != currentLang) {
            // Backend preference differs from device lang → apply it
            ref.read(localizationControllerProvider.notifier).changeLocale(Locale(preferred));
          }
        } else {
          // New user: no preference yet → persist device lang to backend
          _updateLanguageUseCase.call(UpdateLanguageParams(currentLang));
        }
      },
    );
  }

  Future<bool> _loadThemeConfig() async {
    final result = await _getThemeConfigUseCase.call(const NoParams());
    bool success = false;
    result.fold(
      (error) {
        debugPrint('Splash: theme config error: $error');
        if (ref.mounted) {
          state = state.copyWith(
            stateConstant: StateConstant.error,
            isSplashReady: true,
          );
        }
      },
      (theme) {
        // Set the theme first — this triggers TemplateAApp to rebuild MaterialApp
        // with the real colors/fonts. We then wait one frame before marking
        // isSplashReady so both rebuilds don't collide in the same frame.
        ref.read(appThemeNotifierProvider.notifier).setAppTheme(theme);
        success = true;
      },
    );

    if (success) {
      // Yield to the event loop so TemplateAApp finishes its theme rebuild
      // before SplashScreen switches from the loading view to the full splash UI.
      await Future.delayed(Duration.zero);
      if (ref.mounted) {
        state = state.copyWith(
          stateConstant: StateConstant.success,
          isSplashReady: true,
        );
      }
    }

    return success;
  }
}
