import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale/locale.dart';
import 'package:locale/localization_controller.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('Locale Package Integration Tests', () {
    late TranslationRegistry registry;

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('should handle complete workflow: initialize -> use -> change locale',
        () {
      // Step 1: Initialize app translations
      LocaleInitializer.initializeAppTranslations({
        'en': {
          'welcome': 'Welcome',
          'hello': 'Hello',
        },
        'es': {
          'welcome': 'Bienvenido',
          'hello': 'Hola',
        },
        'de': {
          'welcome': 'Willkommen',
          'hello': 'Hallo',
        },
      });

      // Step 2: Verify translations are registered
      expect(registry.getRegisteredLocales(), containsAll(['en', 'es', 'de']));

      // Step 3: Create localizations and verify English
      final enLocalizations = AppLocalizations(const Locale('en'));
      expect(enLocalizations.getTranslatedString('welcome'), equals('Welcome'));
      expect(enLocalizations.getTranslatedString('hello'), equals('Hello'));

      // Step 4: Verify Spanish
      final esLocalizations = AppLocalizations(const Locale('es'));
      expect(
          esLocalizations.getTranslatedString('welcome'), equals('Bienvenido'));
      expect(esLocalizations.getTranslatedString('hello'), equals('Hola'));

      // Step 5: Verify German
      final deLocalizations = AppLocalizations(const Locale('de'));
      expect(
          deLocalizations.getTranslatedString('welcome'), equals('Willkommen'));
      expect(deLocalizations.getTranslatedString('hello'), equals('Hallo'));
    });

    test('should handle feature module translation merging', () {
      // Step 1: Initialize app-level translations
      LocaleInitializer.initializeAppTranslations({
        'en': {
          'appTitle': 'My App',
          'welcome': 'Welcome',
        },
        'es': {
          'appTitle': 'Mi App',
          'welcome': 'Bienvenido',
        },
      });

      // Step 2: Add feature module translations
      LocaleInitializer.registerFeatureTranslations('en', {
        'welcome': 'Welcome to Feature', // Override app translation
        'featureTitle': 'Feature', // New translation
      });

      LocaleInitializer.registerFeatureTranslations('es', {
        'welcome': 'Bienvenido a la Característica',
        'featureTitle': 'Característica',
      });

      // Step 3: Verify merged translations
      final enLocalizations = AppLocalizations(const Locale('en'));
      expect(enLocalizations.getTranslatedString('appTitle'), equals('My App'));
      expect(enLocalizations.getTranslatedString('welcome'),
          equals('Welcome to Feature'));
      expect(enLocalizations.getTranslatedString('featureTitle'),
          equals('Feature'));

      final esLocalizations = AppLocalizations(const Locale('es'));
      expect(esLocalizations.getTranslatedString('appTitle'), equals('Mi App'));
      expect(esLocalizations.getTranslatedString('welcome'),
          equals('Bienvenido a la Característica'));
      expect(esLocalizations.getTranslatedString('featureTitle'),
          equals('Característica'));
    });

    test('should handle fallback when locale not found', () {
      LocaleInitializer.initializeAppTranslations({
        'en': {'hello': 'Hello'},
        'es': {'hello': 'Hola'},
      });

      // Request French which is not registered
      final frLocalizations = AppLocalizations(const Locale('fr'));
      final values = frLocalizations.getLocalizedValues(const Locale('fr'));

      // Should fallback to first available locale (en)
      expect(values['hello'], equals('Hello'));
    });

    test('should handle multiple feature modules', () {
      // App translations
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

      // Feature module 3 (overrides feature 1)
      LocaleInitializer.registerFeatureTranslations('en', {
        'feature1Title': 'Feature 1 Updated',
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('appTitle'), equals('My App'));
      expect(localizations.getTranslatedString('feature1Title'),
          equals('Feature 1 Updated'));
      expect(localizations.getTranslatedString('feature2Title'),
          equals('Feature 2'));
    });

    test('should handle locale controller with translations', () {
      // Initialize translations
      LocaleInitializer.initializeAppTranslations({
        'en': {'hello': 'Hello'},
        'es': {'hello': 'Hola'},
      });

      // Create controller (should default to 'en')
      final controller = LocalizationController();
      expect(controller.state, equals(const Locale('en')));

      // Change locale
      controller.changeLocale(const Locale('es'));
      expect(controller.state, equals(const Locale('es')));

      // Verify translations work with new locale
      final localizations = AppLocalizations(controller.state);
      expect(localizations.getTranslatedString('hello'), equals('Hola'));
    });

    test('should handle empty translations gracefully', () {
      LocaleInitializer.initializeAppTranslations({
        'en': {},
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('anyKey'), equals('anyKey'));
      expect(localizations.getLocalizedValues(const Locale('en')), isEmpty);
    });

    test('should handle special characters and unicode', () {
      LocaleInitializer.initializeAppTranslations({
        'en': {
          'chinese': '你好',
          'japanese': 'こんにちは',
          'arabic': 'مرحبا',
          'emoji': 'Hello 👋 🌍',
          'accent': 'Café résumé',
        },
      });

      final localizations = AppLocalizations(const Locale('en'));
      expect(localizations.getTranslatedString('chinese'), equals('你好'));
      expect(localizations.getTranslatedString('japanese'), equals('こんにちは'));
      expect(localizations.getTranslatedString('arabic'), equals('مرحبا'));
      expect(localizations.getTranslatedString('emoji'), equals('Hello 👋 🌍'));
      expect(
          localizations.getTranslatedString('accent'), equals('Café résumé'));
    });
  });
}
