import 'package:flutter_test/flutter_test.dart';
import 'package:locale/locale_initializer.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('LocaleInitializer', () {
    late TranslationRegistry registry;

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear(); // Clear before each test
    });

    tearDown(() {
      registry.clear(); // Clean up after each test
    });

    test('should initialize app translations', () {
      final translations = {
        'en': {'hello': 'Hello', 'goodbye': 'Goodbye'},
        'es': {'hello': 'Hola', 'goodbye': 'Adiós'},
      };

      LocaleInitializer.initializeAppTranslations(translations);

      expect(registry.getTranslations('en'), equals(translations['en']));
      expect(registry.getTranslations('es'), equals(translations['es']));
      expect(registry.getRegisteredLocales(), containsAll(['en', 'es']));
    });

    test('should register feature translations', () {
      // First initialize app translations
      LocaleInitializer.initializeAppTranslations({
        'en': {'appTitle': 'My App'},
        'es': {'appTitle': 'Mi App'},
      });

      // Then register feature translations
      LocaleInitializer.registerFeatureTranslations('en', {
        'featureTitle': 'Feature',
      });

      LocaleInitializer.registerFeatureTranslations('es', {
        'featureTitle': 'Característica',
      });

      final enTranslations = registry.getTranslations('en');
      final esTranslations = registry.getTranslations('es');

      expect(enTranslations, isNotNull);
      expect(enTranslations!['appTitle'], equals('My App'));
      expect(enTranslations['featureTitle'], equals('Feature'));

      expect(esTranslations, isNotNull);
      expect(esTranslations!['appTitle'], equals('Mi App'));
      expect(esTranslations['featureTitle'], equals('Característica'));
    });

    test('should merge feature translations with app translations', () {
      // Initialize app translations
      LocaleInitializer.initializeAppTranslations({
        'en': {
          'welcome': 'Welcome',
          'appTitle': 'My App',
        },
      });

      // Register feature translations that override app translations
      LocaleInitializer.registerFeatureTranslations('en', {
        'welcome': 'Welcome to Feature', // Override
        'featureTitle': 'Feature', // New
      });

      final translations = registry.getTranslations('en');
      expect(translations, isNotNull);
      expect(translations!['appTitle'], equals('My App'));
      expect(translations['welcome'],
          equals('Welcome to Feature')); // Feature overrides
      expect(translations['featureTitle'], equals('Feature'));
    });

    test('should handle empty translation maps', () {
      LocaleInitializer.initializeAppTranslations({
        'en': {},
        'es': {},
      });

      expect(registry.isLocaleRegistered('en'), isTrue);
      expect(registry.isLocaleRegistered('es'), isTrue);
      expect(registry.getTranslations('en'), equals({}));
      expect(registry.getTranslations('es'), equals({}));
    });

    test('should handle multiple feature modules registering translations', () {
      LocaleInitializer.initializeAppTranslations({
        'en': {'appTitle': 'My App'},
      });

      // Feature module 1
      LocaleInitializer.registerFeatureTranslations('en', {
        'feature1Title': 'Feature 1',
      });

      // Feature module 2
      LocaleInitializer.registerFeatureTranslations('en', {
        'feature2Title': 'Feature 2',
      });

      final translations = registry.getTranslations('en');
      expect(translations, isNotNull);
      expect(translations!['appTitle'], equals('My App'));
      expect(translations['feature1Title'], equals('Feature 1'));
      expect(translations['feature2Title'], equals('Feature 2'));
    });

    test('should handle registering translations for new locale via feature',
        () {
      LocaleInitializer.initializeAppTranslations({
        'en': {'hello': 'Hello'},
      });

      // Feature adds support for a new locale
      LocaleInitializer.registerFeatureTranslations('fr', {
        'hello': 'Bonjour',
      });

      expect(registry.isLocaleRegistered('en'), isTrue);
      expect(registry.isLocaleRegistered('fr'), isTrue);
      expect(registry.getTranslations('fr')!['hello'], equals('Bonjour'));
    });
  });
}
