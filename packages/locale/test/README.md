# Locale Package Tests

This directory contains comprehensive test cases for the locale package.

## Test Files

- **translation_registry_test.dart** - Tests for `TranslationRegistry` singleton
  - Singleton pattern
  - Translation registration and retrieval
  - Translation merging
  - Multiple locale registration
  - Clearing translations
  - Feature module translation merging

- **locale_initializer_test.dart** - Tests for `LocaleInitializer` helper class
  - App translation initialization
  - Feature translation registration
  - Translation merging behavior
  - Multiple feature module support

- **app_localizations_test.dart** - Tests for `AppLocalizations` class
  - Language list retrieval
  - Translation string retrieval
  - Fallback behavior
  - Multiple locale support
  - Special character handling

- **localization_controller_test.dart** - Tests for `LocalizationController`
  - Default locale selection
  - Locale changing
  - State management
  - Country code handling

- **app_localizations_delegate_test.dart** - Tests for `AppLocalizationsDelegate`
  - Delegate list verification
  - Supported locales
  - Locale support checking
  - Synchronous loading
  - Country code handling

- **integration_test.dart** - End-to-end integration tests
  - Complete workflow testing
  - Feature module integration
  - Fallback scenarios
  - Multiple feature modules
  - Special character handling

## Running Tests

### Run all tests
```bash
cd packages/locale
flutter test
```

### Run a specific test file
```bash
flutter test test/translation_registry_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run tests with verbose output
```bash
flutter test --verbose
```

## Test Coverage

The test suite covers:
- ✅ Singleton pattern verification
- ✅ Translation registration and retrieval
- ✅ Translation merging (app + feature modules)
- ✅ Fallback behavior
- ✅ Multiple locale support
- ✅ Special characters and Unicode
- ✅ Empty translation handling
- ✅ Locale controller state management
- ✅ Delegate functionality
- ✅ Integration scenarios

## Adding New Tests

When adding new functionality to the locale package:

1. Add unit tests for the new component
2. Add integration tests if it affects multiple components
3. Update this README if adding new test files
4. Ensure all tests pass before committing

## Test Structure

Each test file follows this structure:
- `setUp()` - Initialize test environment
- `tearDown()` - Clean up after tests
- `group()` - Group related tests
- `test()` - Individual test cases

