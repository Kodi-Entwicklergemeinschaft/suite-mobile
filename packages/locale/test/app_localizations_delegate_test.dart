import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale/localizations.dart';
import 'package:locale/localizations_delegate.dart';
import 'package:locale/translation_registry.dart';

void main() {
  group('AppLocalizationsDelegate', () {
    late TranslationRegistry registry;
    const delegate = AppLocalizationsDelegate();

    setUp(() {
      registry = TranslationRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('should have correct delegate list', () {
      expect(AppLocalizationsDelegate.delegate.length, equals(4));
      expect(AppLocalizationsDelegate.delegate.first,
          isA<AppLocalizationsDelegate>());
    });

    test('should return supported locales from registry', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});
      registry.registerTranslations('de', {'key': 'wert'});

      final supportedLocales = AppLocalizationsDelegate.supportedLocales;
      expect(supportedLocales.length, equals(3));
      expect(
          supportedLocales,
          containsAll([
            const Locale('en'),
            const Locale('es'),
            const Locale('de'),
          ]));
    });

    test('should return empty list when no translations registered', () {
      final supportedLocales = AppLocalizationsDelegate.supportedLocales;
      expect(supportedLocales, isEmpty);
    });

    test('should support registered locales', () {
      registry.registerTranslations('en', {'key': 'value'});
      registry.registerTranslations('es', {'key': 'valor'});

      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isFalse);
    });

    test('should not support unregistered locales', () {
      registry.registerTranslations('en', {'key': 'value'});

      expect(delegate.isSupported(const Locale('fr')), isFalse);
      expect(delegate.isSupported(const Locale('it')), isFalse);
    });

    test('should load AppLocalizations synchronously', () async {
      registry.registerTranslations('en', {'key': 'value'});

      final future = delegate.load(const Locale('en'));
      expect(future, isA<Future<AppLocalizations>>());

      final localizations = await future;
      expect(localizations, isA<AppLocalizations>());
      expect(localizations.locale, equals(const Locale('en')));
    });

    test('should not reload when shouldReload is called', () {
      final oldDelegate = const AppLocalizationsDelegate();
      expect(delegate.shouldReload(oldDelegate), isFalse);
    });

    test('should handle locale with country code', () {
      registry.registerTranslations('en', {'key': 'value'});

      // Should support based on language code only
      expect(delegate.isSupported(const Locale('en', 'US')), isTrue);
      expect(delegate.isSupported(const Locale('en', 'GB')), isTrue);
    });

    test('should update supported locales when translations are added', () {
      expect(AppLocalizationsDelegate.supportedLocales, isEmpty);

      registry.registerTranslations('en', {'key': 'value'});
      // Note: supportedLocales is a getter, so it will reflect current state
      final locales = AppLocalizationsDelegate.supportedLocales;
      expect(locales.length, equals(1));
      expect(locales.first, equals(const Locale('en')));

      registry.registerTranslations('es', {'key': 'valor'});
      final updatedLocales = AppLocalizationsDelegate.supportedLocales;
      expect(updatedLocales.length, equals(2));
    });
  });
}
