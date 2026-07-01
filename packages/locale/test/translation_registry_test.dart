import 'package:flutter_test/flutter_test.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('TranslationRegistry', () {
    late TranslationRegistry registry;

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear(); // Clear before each test
    });

    tearDown(() {
      registry.clear(); // Clean up after each test
    });

    test('should be a singleton', () {
      final instance1 = TranslationRegistry.instance;
      final instance2 = TranslationRegistry.instance;
      expect(instance1, same(instance2));
    });

    test('should register translations for a locale', () {
      const translations = {
        'key1': 'value1',
        'key2': 'value2',
      };

      registry.registerTranslations('en', translations);

      expect(registry.getTranslations('en'), equals(translations));
      expect(registry.isLocaleRegistered('en'), isTrue);
    });

    test('should return null for unregistered locale', () {
      expect(registry.getTranslations('fr'), isNull);
      expect(registry.isLocaleRegistered('fr'), isFalse);
    });

    test('should merge translations when registering same locale twice', () {
      const initialTranslations = {
        'key1': 'value1',
        'key2': 'value2',
      };

      const additionalTranslations = {
        'key2': 'new_value2', // Override existing key
        'key3': 'value3', // New key
      };

      registry.registerTranslations('en', initialTranslations);
      registry.registerTranslations('en', additionalTranslations);

      final result = registry.getTranslations('en');
      expect(result, isNotNull);
      expect(result!['key1'], equals('value1'));
      expect(result['key2'], equals('new_value2')); // Should be overridden
      expect(result['key3'], equals('value3'));
    });

    test('should register multiple locales at once', () {
      final translationsMap = {
        'en': {'hello': 'Hello', 'goodbye': 'Goodbye'},
        'es': {'hello': 'Hola', 'goodbye': 'Adiós'},
        'de': {'hello': 'Hallo', 'goodbye': 'Auf Wiedersehen'},
      };

      registry.registerTranslationsMap(translationsMap);

      expect(registry.getTranslations('en'), equals(translationsMap['en']));
      expect(registry.getTranslations('es'), equals(translationsMap['es']));
      expect(registry.getTranslations('de'), equals(translationsMap['de']));
    });

    test('should get all registered locale codes', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});
      registry.registerTranslations('de', {'key': 'wert'});

      final locales = registry.getRegisteredLocales();
      expect(locales.length, equals(3));
      expect(locales, containsAll(['en', 'es', 'de']));
    });

    test('should return empty list when no locales registered', () {
      expect(registry.getRegisteredLocales(), isEmpty);
    });

    test('should clear all translations', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});

      expect(registry.getRegisteredLocales().length, equals(2));

      registry.clear();

      expect(registry.getRegisteredLocales(), isEmpty);
      expect(registry.getTranslations('en'), isNull);
      expect(registry.getTranslations('es'), isNull);
    });

    test('should handle empty translation maps', () {
      registry.registerTranslations('en', {});
      expect(registry.isLocaleRegistered('en'), isTrue);
      expect(registry.getTranslations('en'), equals({}));
    });

    test('should handle feature module translation merging', () {
      // App-level translations
      registry.registerTranslations('en', {
        'appTitle': 'My App',
        'welcome': 'Welcome',
      });

      // Feature module translations
      registry.registerTranslations('en', {
        'welcome': 'Welcome to Feature', // Override app translation
        'featureTitle': 'Feature', // New feature translation
      });

      final result = registry.getTranslations('en');
      expect(result, isNotNull);
      expect(result!['appTitle'], equals('My App'));
      expect(
          result['welcome'], equals('Welcome to Feature')); // Feature overrides
      expect(result['featureTitle'], equals('Feature'));
    });

    test('should handle special characters in translations', () {
      const translations = {
        'special': 'Hello 世界',
        'emoji': 'Hello 👋',
        'accent': 'Café',
      };

      registry.registerTranslations('en', translations);
      final result = registry.getTranslations('en');

      expect(result, equals(translations));
    });
  });
}
