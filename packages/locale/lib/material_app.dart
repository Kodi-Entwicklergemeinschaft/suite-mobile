import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locale/localization_controller.dart';

DefaultResourceLoaderLanguage _hyphenationLanguageFor(String languageCode) =>
    languageCode == 'de'
        ? DefaultResourceLoaderLanguage.de1996
        : DefaultResourceLoaderLanguage.enUs;

extension LocaleAppExtension on WidgetRef {
  /// Use this extension method to change app locale
  ///
  /// Example:
  /// ```dart
  /// ref.changeLocale(const Locale('es'));
  /// ```
  void changeLocale(Locale locale) {
    read(localizationControllerProvider.notifier).changeLocale(locale);
    // Reload the hyphenation dictionary for the new language so all
    // HyphenatedText widgets in common_components break words correctly.
    initHyphenation(_hyphenationLanguageFor(locale.languageCode));
    engine!.performReassemble();
  }
  
  /// Convenience method to change locale by language code string
  /// 
  /// Example:
  /// ```dart
  /// ref.changeLocaleByCode('es');
  /// ```
  void changeLocaleByCode(String languageCode) {
    changeLocale(Locale(languageCode));
  }
}

///The current [WidgetsBinding]
WidgetsBinding? get engine {
  return WidgetsBinding.instance;
}
