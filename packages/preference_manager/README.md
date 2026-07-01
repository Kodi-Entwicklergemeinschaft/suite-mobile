# Preference Manager

A Flutter package providing unified access to local storage: shared preferences for general app data and secure encrypted storage for sensitive information (tokens, passwords, API keys).

## Features

- **SharedPreferences Integration** - Easy access to general app preferences (strings, integers)
- **Secure Storage** - Encrypted storage for sensitive data with platform-specific encryption (Android: EncryptedSharedPreferences, iOS: Keychain)
- **Riverpod Providers** - Clean, reactive access to both preference types through Riverpod
- **Customizable Options** - Configure Android and iOS security options as needed
- **Simple API** - Minimal, intuitive methods for storing and retrieving data

## Getting Started

### Prerequisites

- Flutter 3.38.0 or higher
- Dart 3.6.0 or higher

### Installation

The package is part of the workspace. Import it in your app's `pubspec.yaml`:

```yaml
dependencies:
  preference_manager:
    path: ../../packages/preference_manager
```

## Initialization

**IMPORTANT:** Initialize preferences in your `main.dart` before running the app.

```dart
import 'package:flutter/material.dart';
import 'package:preference_manager/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await initPreferences();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomePage(),
    );
  }
}
```

## Usage

### Using SharedPreferences (General App Data)

Access general preferences through the `preferenceManagerProvider`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';

// Save data
await ref.read(preferenceManagerProvider).saveString('username', 'john_doe');
await ref.read(preferenceManagerProvider).saveInt('user_id', 123);

// Retrieve data
String? username = ref.read(preferenceManagerProvider).getStringOrNull('username');
String emptyIfNull = ref.read(preferenceManagerProvider).getStringOrEmpty('username');
int userId = ref.read(preferenceManagerProvider).getInt('user_id'); // returns -1 if not found

// Remove data
await ref.read(preferenceManagerProvider).removePreference('username');
```

#### Available Methods

- `Future<bool> saveString(String key, String value)` - Save a string value
- `String? getStringOrNull(String key)` - Get string value or null
- `String getStringOrEmpty(String key)` - Get string value or empty string
- `Future<bool> saveInt(String key, int value)` - Save an integer value
- `int getInt(String key)` - Get integer value (returns -1 if not found)
- `Future<bool> removePreference(String key)` - Remove a preference

### Using SecurePreferences (Sensitive Data)

Access secure storage through the `securePreferencesProvider`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';

// Save sensitive data (tokens, passwords, etc.)
final secure = ref.read(securePreferencesProvider);
await secure.setString('auth_token', 'eyJhbGciOiJIUzI1NiIs...');
await secure.setString('refresh_token', 'eyJhbGciOiJIUzI1NiIs...');

// Retrieve sensitive data
String? token = await secure.getString('auth_token');

// Check if data exists
bool exists = await secure.containsKey('auth_token');

// Remove specific data
await secure.remove('auth_token');

// Clear all secure storage
await secure.clear();
```

#### Available Methods

- `Future<void> setString(String key, String value)` - Store a string securely
- `Future<String?> getString(String key)` - Retrieve a string value
- `Future<bool> containsKey(String key)` - Check if key exists
- `Future<void> remove(String key)` - Remove a specific entry
- `Future<void> clear()` - Clear all entries

### Customizing Security Options

For custom Android/iOS security configurations:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:preference_manager/shared_pref.dart';

// Create custom secure provider with Android options
final customSecureProvider = Provider(
  (ref) {
    return SecurePreferences(
      androidOptions: AndroidOptions(
        resetOnError: true,
        encryptedSharedPreferences: true,
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iosOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_available_when_unlocked,
      ),
    );
  },
);
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preference Manager Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final prefs = ref.read(preferenceManagerProvider);
                await prefs.saveString('username', 'john_doe');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username saved')),
                );
              },
              child: const Text('Save Username'),
            ),
            ElevatedButton(
              onPressed: () async {
                final secure = ref.read(securePreferencesProvider);
                await secure.setString('auth_token', 'secure_token_123');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token saved securely')),
                );
              },
              child: const Text('Save Auth Token'),
            ),
            ElevatedButton(
              onPressed: () {
                final prefs = ref.read(preferenceManagerProvider);
                final username = prefs.getStringOrNull('username');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Username: $username')),
                );
              },
              child: const Text('Get Username'),
            ),
            ElevatedButton(
              onPressed: () async {
                final secure = ref.read(securePreferencesProvider);
                final token = await secure.getString('auth_token');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Token: $token')),
                );
              },
              child: const Text('Get Auth Token'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Architecture

### Layered Design

```
┌─────────────────────────────────────────┐
│         Your App (Consumer)             │
│   ref.watch(preferenceManagerProvider)  │
│   ref.watch(securePreferencesProvider)  │
└──────────────┬──────────────────────────┘
               │
     ┌─────────┴─────────┐
     │                   │
┌────▼──────────────┐   ┌▼──────────────────┐
│ Shared Preferences│   │ Secure Storage    │
│                   │   │                   │
│ AppPreference     │   │ SecurePreferences │
│ Manager           │   │                   │
└────┬──────────────┘   └─┬─────────────────┘
     │                    │
     │         ┌──────────┴──────────┐
     │         │                     │
  ┌──▼──────────────────┐  ┌─────────▼────────┐
  │ SharedPreferences   │  │ FlutterSecure    │
  │ (Flutter SDK)       │  │ Storage (Plugin) │
  └─────────────────────┘  └──────────────────┘
         Android/iOS native storage implementations
```

## Best Practices

1. **Always initialize** - Call `await initPreferences()` in `main()` before running the app
2. **Use providers** - Access preferences through Riverpod providers, not direct instantiation
3. **Separate concerns** - Use SharedPreferences for general data, SecurePreferences for sensitive data
4. **Error handling** - Wrap async operations in try-catch blocks in production code
5. **Security** - Never store sensitive data in SharedPreferences

## Platform Support

- **Android** - API 16+, uses EncryptedSharedPreferences with RSA-OAEP + AES-GCM encryption
- **iOS** - iOS 11+, uses native Keychain
- **Web** - Not supported (not included in this package)

## Additional Information

For more information about:
- [SharedPreferences package](https://pub.dev/packages/shared_preferences)
- [FlutterSecureStorage package](https://pub.dev/packages/flutter_secure_storage)
- [Riverpod state management](https://riverpod.dev)
