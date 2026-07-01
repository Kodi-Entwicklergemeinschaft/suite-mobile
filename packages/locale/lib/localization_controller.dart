import 'dart:ui';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:locale/translation_registry.dart';
import 'package:preference_manager/shared_pref.dart';

var localizationControllerProvider =
    StateNotifierProvider<LocalizationController, Locale>(
        (ref) => LocalizationController(ref.watch(preferenceManagerProvider)));

class LocalizationController extends StateNotifier<Locale> {
  LocalizationController([this._preferences])
      : super(_getDefaultLocale(_preferences)) {
    // Init hyphenation for the resolved startup locale. No logic change —
    // just piggybacks on the locale already determined by _getDefaultLocale.
    initHyphenation(_hyphenationLang(state.languageCode));
  }

  final PreferenceManager? _preferences;

  static Locale _getDefaultLocale(PreferenceManager? preferences) {
    final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
    final registered = TranslationRegistry.instance.getRegisteredLocales();

    if (registered.contains(deviceLocale)) {
      preferences?.saveString('locale', deviceLocale);
      return Locale(deviceLocale);
    }

    preferences?.saveString('locale', 'de');
    return const Locale('de');
  }

  void changeLocale(Locale locale) {
    state = locale;
    _preferences?.saveString('locale', locale.languageCode);
    initHyphenation(_hyphenationLang(locale.languageCode));
  }

  static DefaultResourceLoaderLanguage _hyphenationLang(String code) =>
      code == 'de'
          ? DefaultResourceLoaderLanguage.de1996
          : DefaultResourceLoaderLanguage.enUs;
}
