import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale/localization_controller.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('LocalizationController', () {
    late TranslationRegistry registry;

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('should default to English when no translations registered', () {
      final controller = LocalizationController();
      expect(controller.state, equals(const Locale('en')));
    });

    test('should default to first registered locale when English not available',
        () {
      registry.registerTranslations('es', {'key': 'value'});
      registry.registerTranslations('de', {'key': 'value'});

      final controller = LocalizationController();
      expect(controller.state, equals(const Locale('es')));
    });

    test('should prefer English when available', () {
      registry.registerTranslations('es', {'key': 'value'});
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('de', {'key': 'value'});

      final controller = LocalizationController();
      expect(controller.state, equals(const Locale('en')));
    });

    test('should change locale when changeLocale is called', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});

      final controller = LocalizationController();
      expect(controller.state, equals(const Locale('en')));

      controller.changeLocale(const Locale('es'));
      expect(controller.state, equals(const Locale('es')));

      controller.changeLocale(const Locale('de'));
      expect(controller.state, equals(const Locale('de')));
    });

    test('should handle locale with country code', () {
      registry.registerTranslations('en', {'key': 'value'});

      final controller = LocalizationController();
      controller.changeLocale(const Locale('en', 'US'));
      expect(controller.state.languageCode, equals('en'));
      expect(controller.state.countryCode, equals('US'));
    });

    test('should handle multiple locale changes', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});
      registry.registerTranslations('de', {'key': 'wert'});

      final controller = LocalizationController();

      controller.changeLocale(const Locale('es'));
      expect(controller.state, equals(const Locale('es')));

      controller.changeLocale(const Locale('de'));
      expect(controller.state, equals(const Locale('de')));

      controller.changeLocale(const Locale('en'));
      expect(controller.state, equals(const Locale('en')));
    });

    test('should maintain state across multiple changes', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});

      final controller = LocalizationController();
      final initialState = controller.state;

      controller.changeLocale(const Locale('es'));
      expect(controller.state, isNot(equals(initialState)));

      controller.changeLocale(const Locale('en'));
      expect(controller.state, equals(const Locale('en')));
    });
  });
}
