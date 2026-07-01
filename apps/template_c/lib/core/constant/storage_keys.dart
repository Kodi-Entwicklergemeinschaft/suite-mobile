/// Centralized storage keys for the entire application
///
/// This class contains all SecureStorage keys for authentication.
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  // ==================== Authentication (Secure Storage) ====================
  /// Authentication token keys - stored in SecureStorage
  static const String authAccessToken = 'auth_access_token';
  static const String authRefreshToken = 'auth_refresh_token';
  static const String authExpiresIn = 'auth_expires_in';
  static const String authIsLoggedIn = 'auth_is_logged_in';
  static const String authRole = 'auth_role';
  static const String lat = 'lat';
  static const String long = 'long';
  static const String radius = 'radius';
  static const String selectedLocation = 'selected_location';
  static const String isOnboarded = 'is_onboarded';
  static const String userName = 'user_name';

  // ==================== Device (Shared Preferences) ====================
  /// Device ID for guest authentication - stored once on app startup
  static const String deviceId = 'device_id';

  static const String recentSearchQueries = 'recent_search_queries';
}
