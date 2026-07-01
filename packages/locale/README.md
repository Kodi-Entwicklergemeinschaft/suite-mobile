# Locale Package

A flexible localization package for Flutter that supports translations from template projects and feature modules.

## Features

- ✅ Accept translations from outside the package (template projects)
- ✅ Support for feature modules to add their own translations
- ✅ Automatic translation merging (feature module translations override app-level translations)
- ✅ Easy-to-use API with extension methods
- ✅ Riverpod integration for state management

## Getting Started

### 1. Initialize Translations in Your Template Project

In your template project's `main.dart`, initialize translations before `runApp()`:

```dart
import 'package:locale/locale.dart';
import 'package:template_b/localize_values/en.dart';
import 'package:template_b/localize_values/es.dart';
import 'package:template_b/localize_values/de.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app-level translations
  LocaleInitializer.initializeAppTranslations({
    'en': en,
    'es': es,
    'de': de,
  });
  
  runApp(MyApp());
}
```

### 2. Create Translation Files

Create translation files in your template project (e.g., `lib/localize_values/`):

**lib/localize_values/en.dart:**
```dart
const Map<String, String> en = {
  'loginTitle': 'LOGIN',
  'welcome': 'Welcome',
  'home': 'Home',
};
```

**lib/localize_values/es.dart:**
```dart
const Map<String, String> es = {
  'loginTitle': 'INICIAR SESIÓN',
  'welcome': 'Bienvenido',
  'home': 'Inicio',
};
```

### 3. Configure MaterialApp

Add localization delegates and supported locales to your `MaterialApp` or `MaterialApp.router`:

```dart
import 'package:locale/locale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // ... other properties
      localizationsDelegates: AppLocalizationsDelegate.delegate,
      supportedLocales: AppLocalizationsDelegate.supportedLocales,
      locale: ref.watch(localizationControllerProvider),
      routerConfig: router,
    );
  }
}
```

### 4. Use Translations in Your Code

```dart
import 'package:locale/locale.dart';

// Using extension method
Text('loginTitle'.tr)

// Or using the global instance
Text(AppLocalization.getTranslatedString('loginTitle'))

// Or using Riverpod provider
final localizations = ref.watch(localizationProvider(context));
Text(localizations.getTranslatedString('loginTitle'))
```

## Feature Module Translations

Feature modules can add their own translations that will be merged with app-level translations. Feature module translations take precedence if there are key conflicts.

### Adding Feature Module Translations

In your feature module's initialization code:

```dart
import 'package:locale/locale.dart';
import 'package:my_feature/localize_values/en.dart' as feature_en;
import 'package:my_feature/localize_values/es.dart' as feature_es;

// Initialize feature translations
void initializeFeatureTranslations() {
  LocaleInitializer.registerFeatureTranslations('en', feature_en.translations);
  LocaleInitializer.registerFeatureTranslations('es', feature_es.translations);
}
```

**Best Practice:** Call this initialization in your feature module's entry point or when the feature is first loaded.

### Feature Module Translation File Structure

**packages/features/my_feature/lib/localize_values/en.dart:**
```dart
const Map<String, String> translations = {
  'featureTitle': 'My Feature',
  'featureDescription': 'This is a feature module',
};
```

## Changing Locale

Use the Riverpod extension to change the app locale:

```dart
import 'package:locale/material_app.dart';
import 'package:flutter/material.dart';

// In your widget - using Locale object
ref.changeLocale(const Locale('es'));

// Or using the convenience method with language code
ref.changeLocaleByCode('es');
```

## API Reference

### `LocaleInitializer`

- `initializeAppTranslations(Map<String, Map<String, String>> translations)`: Initialize app-level translations
- `registerFeatureTranslations(String localeCode, Map<String, String> translations)`: Register feature module translations

### `AppLocalizations`

- `getTranslatedString(String key)`: Get translated string for current locale
- `getLocalizedValues(Locale locale)`: Get all translations for a locale
- `languages()`: Get list of supported language codes

### `TranslationRegistry`

- `registerTranslations(String localeCode, Map<String, String> translations)`: Register translations for a locale
- `registerTranslationsMap(Map<String, Map<String, String>> translations)`: Register multiple locales at once
- `getTranslations(String localeCode)`: Get translations for a locale
- `getRegisteredLocales()`: Get all registered locale codes

## Architecture

The package uses a singleton `TranslationRegistry` that holds all translation maps. This allows:

1. **Template projects** to provide base translations via `LocaleInitializer.initializeAppTranslations()`
2. **Feature modules** to add their own translations via `LocaleInitializer.registerFeatureTranslations()`
3. **Automatic merging** where feature module translations override app-level translations for the same keys

## Migration from Old System

If you were using the old system with hardcoded imports:

1. Remove imports from `package:locale/localizeValues/...`
2. Create translation files in your template project
3. Initialize translations in `main()` using `LocaleInitializer.initializeAppTranslations()`
4. Update your `MaterialApp` to include localization delegates

## Additional Information

For more information about Flutter localization, see the [Flutter Internationalization guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization).
