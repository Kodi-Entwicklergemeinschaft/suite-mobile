/// Centralized API endpoints for the entire application
/// Based on HEIDI API - Authentication Endpoints.md
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base API path
  static const String apiBase = '/api';

  // ==================== Authentication ====================
  /// Authentication endpoints (from HEIDI API spec)
  static const String authBase = '$apiBase/auth';
  static const String authLogin = '$authBase/login';
  static const String authRegister = '$authBase/register';
  static const String authRefresh = '$authBase/refresh';
  static const String authLogout = '$authBase/logout';
  static const String authPasswordReset = '$authBase/password-reset/request';
  static const String authChangePassword = '$authBase/change-password';
  static const String authGuestLogin = '$authBase/guest';
  static const String authGuestRegister = '$authBase/guest/register';

  // ==================== Theme ====================
  /// Theme configuration endpoints
  static const String themeBase = '$apiBase/app-config/theme';
  static const String themeConfig = themeBase;

  // ==================== Profile ====================
  /// Profile endpoints
  static const String profileBase = '$apiBase/users';
  static const String profileGet = '$profileBase/profile';
  static const String profileUpdate = profileBase;
  static const String profileDelete = profileBase;
  static const String profileChangePassword = '$profileBase/change-password';

  // ==================== Home ====================
  /// Home endpoints
  static const String homeConfig = '$apiBase/home/config';
  static const String localityToggle = '$apiBase/localities/toggle';

  // ==================== SERVICES ====================
  /// Service endpoints
  static const String serviceConfig = '$apiBase/app-config/services';

  // ==================== BOTTOM NAV BAR ====================
  /// Bottom nav endpoint

  static const String bottomNavConfig = '$apiBase/app-config/bottom-nav';

  // ==================== DAHBOARD ====================
  /// dashboard endpoint

  static const String dashboardConfig = '$apiBase/app-config/dashboard';

  // ==================== SHORT CODE ====================
  /// short code endpoint

  static const String shortCodeConfig = '$apiBase/auth/ott/session';

  // ==================== IMAGE UPLOAD / DELETE ====================
  /// image upload endpoint
  static const String imageUpload = '$apiBase/users/media/upload';

  /// image delete endpoint
  static const String imageDelete = '$apiBase/users/media/delete';

  // ==================== FEEDBACK ====================
  /// feedback endpoint

  static const String feedbackConfig = '$apiBase/support/feedback';

  // ==================== CONTACT US ====================
  /// contact us endpoint

  static const String contactUsConfig = '$apiBase/support/contact-us';

  // ==================== LEGAL ====================
  /// legal config endpoint (imprint, privacy policy, terms of use)
  static const String legalConfig = '$apiBase/app-config/legal';

  // ==================== FAQ ====================
  /// FAQ endpoint

  static const String faqConfig = '$apiBase/support/faq';
}
