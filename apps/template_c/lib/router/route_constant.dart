enum RouteConstant {
  onboarding('onboarding', '/onboarding'),
  bottomNav('bottom_nav', '/bottom_nav'),
  fav('favourites', '/favourites'),
  search('search', '/search'),
  home('home', '/home'),
  signup('create_account', '/create_account'),
  signin('sign_in', '/sign_in'),
  locationOnboarding('location_onboarding', '/location_onboarding'),
  splash('splash', '/splash'),
  listingDetail('listing_detail', '/listing/:id'),
  listingScreen('category', '/listing/all'),
  editProfile('edit_profile', '/edit_profile'),
  changePassword('change_password', '/change_password'),
  legal('legal', '/legal'),
  subService('sub_service', '/sub_service'),
  commonWebView('common_web_view', '/common_web_view'),
  interestSelection('interest_selection', '/interest_selection');

  final String name;
  final String path;

  const RouteConstant(this.name, this.path);
}
