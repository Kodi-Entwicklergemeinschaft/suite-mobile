import 'package:go_router/go_router.dart';
import 'package:template_c/feat/auth/presentation/signin_screen.dart';
import 'package:template_c/feat/auth/presentation/signup_screen.dart';
import 'package:template_c/feat/bottom_navigation/presentation/bottom_navigation_screen.dart';
import 'package:template_c/feat/fav/presentation/fav_screen.dart';
import 'package:template_c/feat/home/presentation/home_screen.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_screen.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/profile/presentation/change_password_screen.dart';
import 'package:template_c/feat/profile/presentation/edit_profile_screen.dart';
import 'package:template_c/feat/profile/presentation/legal_screen.dart';
import 'package:template_c/feat/search/presentation/search_screen.dart';
import 'package:template_c/feat/onboarding/presentation/onboarding_screen.dart';
import 'package:template_c/feat/splash/presentation/splash_screen.dart';
import 'package:template_c/feat/listing/ui/listing_detail_screen.dart';
import 'package:template_c/feat/listing/ui/listing_screen.dart';
import 'package:template_c/feat/listing/params/listing_screen_params.dart';
import 'package:template_c/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';

final appRoute = <GoRoute>[
  GoRoute(
    path: RouteConstant.splash.path,
    name: RouteConstant.splash.name,
    builder: (context, state) => SplashScreen(),
  ),

  GoRoute(
    path: RouteConstant.onboarding.path,
    name: RouteConstant.onboarding.name,
    builder: (context, state) => OnboardingScreen(),
  ),
  GoRoute(
    path: RouteConstant.home.path,
    name: RouteConstant.home.name,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: RouteConstant.search.path,
    name: RouteConstant.search.name,
    builder: (context, state) => SearchScreen(),
  ),
  GoRoute(
    path: RouteConstant.fav.path,
    name: RouteConstant.fav.name,
    builder: (context, state) => FavScreen(),
  ),
  GoRoute(
    path: RouteConstant.bottomNav.path,
    name: RouteConstant.bottomNav.name,
    builder: (context, state) => BottomNavigationScreen(),
  ),
  GoRoute(
    path: RouteConstant.signup.path,
    name: RouteConstant.signup.name,
    builder: (context, state) => SignupScreen(),
  ),
  GoRoute(
    path: RouteConstant.signin.path,
    name: RouteConstant.signin.name,
    builder: (context, state) => SigninScreen(),
  ),

  GoRoute(
    path: RouteConstant.locationOnboarding.path,
    name: RouteConstant.locationOnboarding.name,
    builder: (context, state) {
      return LocationOnboardingScreen(
        locationOnboardingParams: state.extra as LocationOnboardingParams,
      );
    },
  ),
  GoRoute(
    path: RouteConstant.listingScreen.path,
    name: RouteConstant.listingScreen.name,
    builder: (context, state) {
      final extra = state.extra;
      final params = extra is ListingScreenParams
          ? extra
          : ListingScreenParams.fromMap(extra as Map<String, dynamic>);
      return ListingScreen(params: params);
    },
  ),
  GoRoute(
    path: RouteConstant.listingDetail.path,
    name: RouteConstant.listingDetail.name,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final familyKey = state.uri.queryParameters['familyKey'] ?? '';
      return ListingDetailScreen(listingId: id, familyKey: familyKey);
    },
  ),

  GoRoute(
    path: RouteConstant.editProfile.path,
    name: RouteConstant.editProfile.name,
    builder: (context, state) => EditProfileScreen(),
  ),

  GoRoute(
    path: RouteConstant.changePassword.path,
    name: RouteConstant.changePassword.name,
    builder: (context, state) => ChangePasswordScreen(),
  ),
  GoRoute(
    path: RouteConstant.legal.path,
    name: RouteConstant.legal.name,
    builder: (context, state) => LegalScreen(),
  ),
  GoRoute(
    name: RouteConstant.subService.name,
    path: RouteConstant.subService.path,
    builder: (context, state) =>
        SubServiceScreen(params: state.extra as SubServiceScreenParams),
  ),
  GoRoute(
    name: RouteConstant.commonWebView.name,
    path: RouteConstant.commonWebView.path,
    builder: (context, state) =>
        CommonWebViewWidget(params: state.extra as CommonWebViewWidgetParams),
  ),
  GoRoute(
    path: RouteConstant.interestSelection.path,
    name: RouteConstant.interestSelection.name,
    builder: (context, state) {
      return InterestSelectionScreen(
        interestSelectionParams: state.extra as InterestSelectionParams,
      );
    },
  ),
];
