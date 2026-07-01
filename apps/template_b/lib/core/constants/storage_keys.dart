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
  static const String isGuestUser = 'is_guest_user';

  // ==================== Device (Shared Preferences) ====================
  /// Device ID for guest authentication - stored once on app startup
  static const String deviceId = 'device_id';

  // ==================== Feature: Defect Report ====================
  // Cleared on logout/session-expiry even when the feature is disabled,
  // so a stale selection is never restored after re-enabling the feature.
  static const String defectReportLastSelectedLocation =
      'defect_report_last_selected_location';
}
