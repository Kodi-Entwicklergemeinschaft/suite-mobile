part of 'shared_pref.dart';

late AppPreferenceManager _preferenceManagerInstance;

// ignore: library_private_types_in_public_api, non_constant_identifier_names
AppPreferenceManager get _preferenceManager => _preferenceManagerInstance;

/// Initializes both SharedPreferences and SecurePreferences.
///
/// Must be called once during app startup (before runApp or in splash).
/// SecurePreferences handles iOS keychain cleanup on reinstall automatically.
Future<void> initPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _preferenceManagerInstance = AppPreferenceManager(prefs);

  // Initialize secure storage with first-launch cleanup for iOS
  await SecurePreferences.init(sharedPreferences: prefs);
}

final preferenceManagerProvider = Provider((ref) {
  return _preferenceManager;
});

/// Provides the initialized [SecurePreferences] singleton.
///
/// Requires [initPreferences] to have been called first (during app startup).
/// Throws [StateError] if accessed before initialization.
final securePreferencesProvider = Provider<SecurePreferences>((ref) {
  return SecurePreferences.instance;
});
