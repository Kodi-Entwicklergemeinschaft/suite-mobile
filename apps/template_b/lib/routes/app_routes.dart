import 'package:go_router/go_router.dart';
import 'package:template_b/feat/bottom_navigation/presentation/bottom_navigation.dart';
import 'package:template_b/feat/connectivity/presentation/connectivity_screen.dart';
import 'package:template_b/feat/contact/presentation/contact_screen.dart';
import 'package:template_b/feat/linkhub_service/routes/linkhub_service_routes.dart';
import 'package:template_b/feat/locality/presentation/digital_townhall_locality_screen.dart';
import 'package:template_b/feat/locality/presentation/defect_reporter_locality_screen.dart';
import 'package:template_b/feat/feedback/presentation/feedback_screen.dart';
import 'package:template_b/feat/dashbboard/presentation/dashboard_screen.dart';
import 'package:template_b/feat/home/ui/home_screen.dart';
import 'package:template_b/feat/profile/presentation/screens/edit_profile_screen.dart';
import 'package:template_b/feat/profile/presentation/screens/my_profile_screen.dart';
import 'package:template_b/feat/profile/presentation/screens/profile_settings_screen.dart';
import 'package:template_b/feat/auth/ui/change_password_screen.dart';
import 'package:template_b/feat/profile/presentation/screens/legal_screen.dart';
import 'package:template_b/feat/services/presentation/services_screen.dart';
import 'package:template_b/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_b/feat/settings/presentation/settings_screen.dart';
import 'package:template_b/feat/splash/presentation/splash_screen.dart';
import 'package:template_b/feat/auth/ui/signin_screen.dart';
import 'package:template_b/feat/auth/ui/signup_screen.dart';
import 'package:template_b/feat/auth/ui/forgot_password_screen.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:common_components/src/widgets/common_pdf_viewer_widget/common_pdf_viewer_widget.dart';
import 'package:template_b/feat/upload_ad/presentation/upload_ad_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_detail_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_filter_page.dart';

enum AppRouteConstants {
  splash('splash', "/splash"),
  signIn('sign_in', '/sign_in'),
  signUp('sign_up', '/sign_up'),
  forgotPassword('forgot_password', '/forgot_password'),
  bottomNavigation('bottom_navigation', "/bottom_navigation"),
  subService('sub_service', '/sub_service'),
  commonWebView('common_web_view', '/common_web_view'),
  services('services', "/services"),
  home('home', "/home"),
  myProfile('profile', '/profile'),
  editProfile('edit_profile', '/edit'),
  profileSettings('profile_settings', '/profile-settings'),
  changePassword('change_password', '/change-password'),
  legal('legal', '/legal'),
  settings('settings', '/settings'),
  uploadAd('upload_ad', '/upload_ad'),
  dashboardScreen("dashboard", "/dashboard"),
  feedback('feedback', "/feedback"),
  contact('feature_contact', '/feature_contact'),
  featureListing('category', '/listings'),
  featureListingDetail('feature_listing_detail', '/listing_detail'),
  featureListingFilter('feature_listing_filter', '/listing_filter'),
  linkhubScreen('linkhub-screen', '/linkhub/screen'),
  commonPdfViewer('common_pdf_viewer', '/common_pdf_viewer'),
  locationSelectionDefectReport(
    'defect-report-location',
    '/defect-report/location',
  ),
  localitySelectionTownHall('locality-selection', '/locality/location');

  final String name;
  final String path;
  const AppRouteConstants(this.name, this.path);
}

List<GoRoute> appRoute = [
  GoRoute(
    path: AppRouteConstants.splash.path,
    name: AppRouteConstants.splash.name,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: AppRouteConstants.signIn.path,
    name: AppRouteConstants.signIn.name,
    builder: (context, state) => const SignInScreen(),
  ),
  GoRoute(
    path: AppRouteConstants.signUp.path,
    name: AppRouteConstants.signUp.name,
    builder: (context, state) => const SignUpScreen(),
  ),
  GoRoute(
    path: AppRouteConstants.forgotPassword.path,
    name: AppRouteConstants.forgotPassword.name,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AppRouteConstants.bottomNavigation.path,
    name: AppRouteConstants.bottomNavigation.name,
    builder: (context, state) => const BottomNavigation(),
  ),
  GoRoute(
    name: AppRouteConstants.home.name,
    path: AppRouteConstants.home.path,
    builder: (context, state) => const HomeScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.services.name,
    path: AppRouteConstants.services.path,
    builder: (context, state) => const ServiceScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.subService.name,
    path: AppRouteConstants.subService.path,
    builder: (context, state) =>
        SubServiceScreen(params: state.extra as SubServiceScreenParams),
  ),

  GoRoute(
    name: AppRouteConstants.commonWebView.name,
    path: AppRouteConstants.commonWebView.path,
    builder: (context, state) =>
        CommonWebViewWidget(params: state.extra as CommonWebViewWidgetParams),
  ),
  GoRoute(
    name: AppRouteConstants.commonPdfViewer.name,
    path: AppRouteConstants.commonPdfViewer.path,
    builder: (context, state) => CommonPdfViewerWidget(
      params: state.extra as CommonPdfViewerWidgetParams,
    ),
  ),
  GoRoute(
    name: AppRouteConstants.myProfile.name,
    path: AppRouteConstants.myProfile.path,
    builder: (context, state) => const MyProfileScreen(),
    routes: [
      GoRoute(
        name: AppRouteConstants.editProfile.name,
        path: AppRouteConstants.editProfile.path,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        name: AppRouteConstants.profileSettings.name,
        path: AppRouteConstants.profileSettings.path,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        name: AppRouteConstants.changePassword.name,
        path: AppRouteConstants.changePassword.path,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        name: AppRouteConstants.legal.name,
        path: AppRouteConstants.legal.path,
        builder: (context, state) => const LegalScreen(),
      ),
    ],
  ),
  GoRoute(
    name: AppRouteConstants.settings.name,
    path: AppRouteConstants.settings.path,
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    name: AppRouteConstants.dashboardScreen.name,
    path: AppRouteConstants.dashboardScreen.path,
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    name: AppRouteConstants.uploadAd.name,
    path: AppRouteConstants.uploadAd.path,
    builder: (context, state) => const UploadAdScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.feedback.name,
    path: AppRouteConstants.feedback.path,
    builder: (context, state) => const FeedbackScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.contact.name,
    path: AppRouteConstants.contact.path,
    builder: (context, state) => const ContactScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.featureListing.name,
    path: AppRouteConstants.featureListing.path,
    builder: (context, state) {
      final params = state.extra is ListingScreenParams
          ? state.extra as ListingScreenParams
          : ListingScreenParams.fromRawConfig(
              state.extra as Map<String, dynamic>?,
            );
      return ListingScreen(params: params);
    },
  ),

  GoRoute(
    name: AppRouteConstants.featureListingFilter.name,
    path: AppRouteConstants.featureListingFilter.path,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final familyKey = extra['familyKey'] as String? ?? 'default_screen';
      final categorySlug = extra['categorySlug'] as String? ?? 'default';
      return ListingFilterPage(
        familyKey: familyKey,
        categorySlug: categorySlug,
      );
    },
  ),

  GoRoute(
    name: AppRouteConstants.featureListingDetail.name,
    path: AppRouteConstants.featureListingDetail.path,
    builder: (context, state) {
      final params = state.extra as ListingDetailScreenParams?;
      return ListingDetailScreen(
        listingId: params?.listingId ?? '',
        bySlug: params?.bySlug ?? false,
      );
    },
  ),

  GoRoute(
    name: AppRouteConstants.localitySelectionTownHall.name,
    path: AppRouteConstants.localitySelectionTownHall.path,
    builder: (context, state) => const DigitalTownhallLocalityScreen(),
  ),

  GoRoute(
    name: AppRouteConstants.locationSelectionDefectReport.name,
    path: AppRouteConstants.locationSelectionDefectReport.path,
    builder: (context, state) => const DefectReporterLocalityScreen(),
  ),

  ...linkhubServiceRoutes,
];
