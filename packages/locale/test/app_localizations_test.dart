import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale/localizations.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('AppLocalizations', () {
    late TranslationRegistry registry;

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('should return list of registered languages', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});
      registry.registerTranslations('de', {'key': 'wert'});

      final languages = AppLocalizations.languages();
      expect(languages.length, equals(3));
      expect(languages, containsAll(['en', 'es', 'de']));
    });

    test('should return empty list when no translations registered', () {
      final languages = AppLocalizations.languages();
      expect(languages, isEmpty);
    });

    test('should get translated string for existing key', () {
      registry.registerTranslations('en', {
        'hello': 'Hello',
        'goodbye': 'Goodbye',
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('hello'), equals('Hello'));
      expect(localizations.getTranslatedString('goodbye'), equals('Goodbye'));
    });

    test('should return key when translation not found', () {
      registry.registerTranslations('en', {
        'hello': 'Hello',
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('nonexistent'),
          equals('nonexistent'));
    });

    test('should return key when locale not registered and no translations exist', () {
      // Don't register any translations - test when registry is empty
      final localizations = AppLocalizations(const Locale('fr'));
      expect(localizations.getTranslatedString('hello'), equals('hello'));
    });

    test('should get localized values for registered locale', () {
      final translations = {
        'key1': 'value1',
        'key2': 'value2',
      };

      registry.registerTranslations('en', translations);

      final localizations = AppLocalizations(const Locale('en'));
      final values = localizations.getLocalizedValues(const Locale('en'));

      expect(values, equals(translations));
    });

    test(
        'should fallback to first available locale when requested locale not found',
        () {
      registry.registerTranslations('en', {'hello': 'Hello'});
      registry.registerTranslations('es', {'hello': 'Hola'});

      final localizations = AppLocalizations(const Locale('fr'));
      final values = localizations.getLocalizedValues(const Locale('fr'));

      // Should fallback to 'en' (first registered)
      expect(values['hello'], equals('Hello'));
    });

    test('should return empty map when no translations registered', () {
      final localizations = AppLocalizations(const Locale('en'));
      final values = localizations.getLocalizedValues(const Locale('en'));

      expect(values, isEmpty);
    });

    test('should handle different locales correctly', () {
      registry.registerTranslations('en', {'hello': 'Hello'});
      registry.registerTranslations('es', {'hello': 'Hola'});
      registry.registerTranslations('de', {'hello': 'Hallo'});

      final enLocalizations = AppLocalizations(const Locale('en'));
      final esLocalizations = AppLocalizations(const Locale('es'));
      final deLocalizations = AppLocalizations(const Locale('de'));

      expect(enLocalizations.getTranslatedString('hello'), equals('Hello'));
      expect(esLocalizations.getTranslatedString('hello'), equals('Hola'));
      expect(deLocalizations.getTranslatedString('hello'), equals('Hallo'));
    });

    test('should handle empty translation values', () {
      registry.registerTranslations('en', {
        'empty': '',
        'normal': 'Normal',
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('empty'), equals(''));
      expect(localizations.getTranslatedString('normal'), equals('Normal'));
    });

    test('should handle special characters in translations', () {
      registry.registerTranslations('en', {
        'special': 'Hello 世界',
        'emoji': 'Hello 👋',
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('special'), equals('Hello 世界'));
      expect(localizations.getTranslatedString('emoji'), equals('Hello 👋'));
    });
  });
}
