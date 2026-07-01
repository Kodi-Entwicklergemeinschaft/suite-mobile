enum RouteConstant {
  splash('splash', '/splash'),
  onboarding('onboarding', '/onboarding'),
  signin('sign_in', '/sign_in'),
  search('search', '/search'),
  termsConditions('terms_conditions', '/terms_conditions'),
  userPreferences('user_preferences', '/user_preferences'),
  subService('sub_service', '/sub_service'),
  serviceHub('service_hub', '/service_hub'),
  parking('parking', '/parking'),
  listing('listing', '/listing'),
  listingDetail('listing_detail', '/listing_detail'),
  userProfileEdit('user_profile_edit', '/user/profile/edit'),
  userSettings('user_settings', '/user/settings'),
  userSettingsLanguage('user_settings_language', '/user/settings/language'),
  userSettingsTheme('user_settings_theme', '/user/settings/theme'),
  userSettingsResetPassword('user_settings_reset_password', '/user/settings/reset_password'),
  userSettingsNotifications('user_settings_notifications', '/user/settings/notifications'),
  listingFilter('listing_filter', '/listing/filter'),
  webView('web_view', '/web_view');

  final String name;
  final String path;

  const RouteConstant(this.name, this.path);
}
