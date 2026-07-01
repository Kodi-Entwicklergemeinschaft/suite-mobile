class ApiEndpoints {
  ApiEndpoints._();

  static const String apiBase = '/api';

  // Auth
  static const String authBase = '$apiBase/auth';
  static const String authLogin = '$authBase/login';
  static const String authRegister = '$authBase/register';
  static const String authRefresh = '$authBase/refresh';
  static const String authLogout = '$authBase/logout';
  static const String authPasswordReset = '$authBase/password-reset/request';
  static const String authChangePassword = '$authBase/change-password';
  static const String authGuestLogin = '$authBase/guest';
  static const String authGuestRegister = '$authBase/guest/register';

  // Theme
  static const String themeBase = '$apiBase/app-config/theme';
  static const String themeConfig = themeBase;

  // Profile
  static const String profileBase = '$apiBase/users';
  static const String profileGet = '$profileBase/profile';
  static const String profileUpdate = profileBase;
  static const String profileDelete = profileBase;
  static const String profileChangePassword = '$profileBase/change-password';
  static const String profileMe = '$profileBase/profile/me';
  static const String salutations = '$profileBase/salutations';
  static const String profilePreferences = '$profileBase/me/preferences';
  static const String mePreferences = '$apiBase/me/preferences';

  // Home
  static const String homeConfig = '$apiBase/app-config/homepage';
  static const String localityToggle = '$apiBase/localities/toggle';

  // Services
  static const String serviceConfig = '$apiBase/app-config/services';

  // Bottom Nav
  static const String bottomNavConfig = '$apiBase/app-config/bottom-nav';

  // Dashboard
  static const String dashboardConfig = '$apiBase/app-config/dashboard';

  // Short Code
  static const String shortCodeConfig = '$apiBase/auth/ott/session';

  // Image Upload / Delete
  static const String imageUpload = '$apiBase/users/media/upload';
  static const String imageDelete = '$apiBase/users/media/delete';

  // Feedback
  static const String feedbackConfig = '$apiBase/support/feedback';

  // Contact Us
  static const String contactUsConfig = '$apiBase/support/contact-us';

  // Legal
  static const String legalConfig = '$apiBase/app-config/legal';

  // FAQ
  static const String faqConfig = '$apiBase/support/faq';

  // Listings
  static const String listings = '$apiBase/listings';
  static const String listingFilters = '$apiBase/listings/filters';

  // Categories
  static const String categoriesWithFilters = '$apiBase/app-config/categories/with-filters';
  static const String categories = '$apiBase/categories';

  // City
  static const String cityLanguages = '$apiBase/city/languages';

  // Parking
  static const String parkingSpaces = '$apiBase/parking/spaces';

  // Favourites
  static const String favListingBase = '$apiBase/listings';
  static const String favSuffix = '/favorite';
  static const String getFavListings = '$apiBase/listings/me/favorites';
  static const String getFavCategories = '$apiBase/listings/me/favorites/categories';

  // Onboarding
  static const String toggleOnboardedStatus = '$apiBase/users/me/onboarded';
}
