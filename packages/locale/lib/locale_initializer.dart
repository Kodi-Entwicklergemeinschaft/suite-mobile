import 'package:locale/translation_registry.dart';

/// Helper class to initialize translations from template project or feature modules
class LocaleInitializer {
  /// Initialize translations from a map of locale codes to translation maps.
  /// This is typically called in the main() function before runApp().
  /// 
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   
  ///   // Initialize app-level translations
  ///   LocaleInitializer.initializeAppTranslations({
  ///     'en': enTranslations,
  ///     'es': esTranslations,
  ///   });
  ///   
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initializeAppTranslations(Map<String, Map<String, String>> translations) {
    TranslationRegistry.instance.registerTranslationsMap(translations);
  }

  /// Register translations for a single locale.
  /// Useful for feature modules to add their own translations.
  /// 
  /// Example:
  /// ```dart
  /// // In a feature module
  /// LocaleInitializer.registerFeatureTranslations('en', {
  ///   'featureKey': 'Feature Value',
  /// });
  /// ```
  static void registerFeatureTranslations(String localeCode, Map<String, String> translations) {
    TranslationRegistry.instance.registerTranslations(localeCode, translations);
  }
}

