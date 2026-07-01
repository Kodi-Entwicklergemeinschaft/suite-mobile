import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locale/translation_registry.dart';

late AppLocalizations _appLocalizationInstance;

// ignore: library_private_types_in_public_api, non_constant_identifier_names
AppLocalizations get AppLocalization => _appLocalizationInstance;

void initAppLocalizations(BuildContext context) {
  _appLocalizationInstance = AppLocalizations.of(context);
}

final localizationProvider = Provider.family<AppLocalizations, BuildContext>(
    (ref, context) => AppLocalizations.of(context));

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static List<String> languages() {
    final registeredLocales =
        TranslationRegistry.instance.getRegisteredLocales();
    return registeredLocales;
  }

  String getTranslatedString(String key, [Map<String, String>? placeholders]) {
    try {
      final translations = getLocalizedValues(locale);
      String value = translations[key] ?? key;
      if (placeholders != null && placeholders.isNotEmpty) {
        placeholders.forEach((k, v) => value = value.replaceAll('{$k}', v));
      }
      return value;
    } catch (e) {
      return key;
    }
  }

  Map<String, String> getLocalizedValues(Locale locale) {
    final registry = TranslationRegistry.instance;
    final translations = registry.getTranslations(locale.languageCode);

    if (translations != null && translations.isNotEmpty) {
      return translations;
    }

    // Fallback to first available locale if requested locale not found
    final registeredLocales = registry.getRegisteredLocales();
    if (registeredLocales.isNotEmpty) {
      final fallbackTranslations =
          registry.getTranslations(registeredLocales.first);
      if (fallbackTranslations != null) {
        return fallbackTranslations;
      }
    }

    // Last resort: return empty map
    return {};
  }
}

extension AppLocalizationHelper on String {
  /// get translated value of Selected Locale
  String get tr => AppLocalization.getTranslatedString(this);

  /// get translated value with placeholder values
  String trParams(Map<String, String> placeholders) =>
      AppLocalization.getTranslatedString(this, placeholders);
}
