/// Registry that holds all translation maps for different locales.
/// This allows translations to be provided from outside the package.
class TranslationRegistry {
  TranslationRegistry._();

  static final TranslationRegistry _instance = TranslationRegistry._();
  static TranslationRegistry get instance => _instance;

  /// Map of locale code to translation map
  final Map<String, Map<String, String>> _translations = {};

  /// Initialize translations for a locale
  /// This merges with existing translations if any, allowing feature modules
  /// to add their own translations
  void registerTranslations(
      String localeCode, Map<String, String> translations) {
    if (_translations.containsKey(localeCode)) {
      // Merge translations, with new translations taking precedence
      _translations[localeCode] = {
        ..._translations[localeCode]!,
        ...translations,
      };
    } else {
      _translations[localeCode] = translations;
    }
  }

  /// Register multiple locales at once
  void registerTranslationsMap(Map<String, Map<String, String>> translations) {
    translations.forEach((localeCode, translationMap) {
      registerTranslations(localeCode, translationMap);
    });
  }

  /// Get translations for a locale
  Map<String, String>? getTranslations(String localeCode) {
    return _translations[localeCode];
  }

  /// Get all registered locale codes
  List<String> getRegisteredLocales() {
    return _translations.keys.toList();
  }

  /// Clear all translations (useful for testing)
  void clear() {
    _translations.clear();
  }

  /// Check if a locale is registered
  bool isLocaleRegistered(String localeCode) {
    return _translations.containsKey(localeCode);
  }
}
