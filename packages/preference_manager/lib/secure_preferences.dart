import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used in SharedPreferences to track first app launch.
/// SharedPreferences is cleared on uninstall, while iOS Keychain persists.
/// This allows us to detect reinstalls and clear stale keychain data.
const _kFirstLaunchKey = 'secure_storage_first_launch_done';

/// Secure storage wrapper for sensitive data using encrypted storage.
///
/// Provides a simple interface for storing and retrieving sensitive data
/// (tokens, passwords, API keys, etc.) with platform-specific encryption.
///
/// Must be initialized via [SecurePreferences.init] before use. Initialization:
/// - Configures iOS Keychain with recommended accessibility settings
/// - Clears stale keychain data on iOS reinstall (keychain persists after uninstall)

class SecurePreferences {
  SecurePreferences._({required FlutterSecureStorage storage})
      : _storage = storage;

  final FlutterSecureStorage _storage;

  /// Whether initialization completed successfully.
  static bool _initialized = false;

  /// Singleton instance after initialization.
  static SecurePreferences? _instance;

  /// Creates and initializes a [SecurePreferences] instance.
  ///
  /// Handles iOS-specific setup:
  /// - Configures Keychain with first_unlock accessibility
  /// - Clears stale keychain data on first launch/reinstall
  ///
  /// [sharedPreferences] is required to detect first launch (for iOS reinstall cleanup).
  static Future<SecurePreferences> init({
    required SharedPreferences sharedPreferences,
  }) async {
    if (_initialized && _instance != null) {
      return _instance!;
    }

    developer.log(
      'Initializing SecurePreferences...',
      name: 'SecurePreferences',
    );

    final storage = FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked,
      ),
    );

    final instance = SecurePreferences._(storage: storage);

    // On iOS, keychain data persists after app uninstall.
    // Use SharedPreferences (which IS cleared on uninstall) to detect reinstalls
    // and purge stale keychain entries.
    if (Platform.isIOS) {
      await _handleFirstLaunchCleanup(
        storage: storage,
        sharedPreferences: sharedPreferences,
      );
    }

    _instance = instance;
    _initialized = true;

    developer.log(
      'SecurePreferences initialized successfully',
      name: 'SecurePreferences',
    );

    return instance;
  }

  /// Returns the initialized instance. Throws if [init] has not been called.
  static SecurePreferences get instance {
    if (!_initialized || _instance == null) {
      throw StateError(
        'SecurePreferences not initialized. Call SecurePreferences.init() first.',
      );
    }
    return _instance!;
  }

  /// Clears stale keychain data on first launch after a reinstall (iOS only).
  static Future<void> _handleFirstLaunchCleanup({
    required FlutterSecureStorage storage,
    required SharedPreferences sharedPreferences,
  }) async {
    final isFirstLaunchDone = sharedPreferences.getBool(_kFirstLaunchKey) ?? false;

    if (!isFirstLaunchDone) {
      developer.log(
        'First launch detected (or reinstall). Clearing stale keychain data.',
        name: 'SecurePreferences',
      );
      try {
        await storage.deleteAll();
      } catch (e) {
        developer.log(
          'Warning: Failed to clear keychain on first launch: $e',
          name: 'SecurePreferences',
          error: e,
        );
      }
      await sharedPreferences.setBool(_kFirstLaunchKey, true);
    }
  }

  /// Stores a string [value] with the given [key] in secure storage.
  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Retrieves a string value for the given [key] from secure storage.
  ///
  /// Returns `null` if the key doesn't exist or if the value cannot be read.
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      developer.log(
        'Error reading key "$key": $e',
        name: 'SecurePreferences',
        error: e,
      );
      return null;
    }
  }

  /// Removes the value for the given [key] from secure storage.
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Removes all stored values from secure storage.
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Checks if a [key] exists in secure storage.
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}
