import 'package:template_b/feat/contact/presentation/contact_screen.dart';
import 'package:template_b/feat/dashbboard/presentation/dashboard_screen.dart';
import 'package:template_b/feat/feedback/presentation/feedback_screen.dart';
import 'package:template_b/feat/home/ui/home_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_screen.dart';
import 'package:template_b/feat/services/presentation/services_screen.dart';
import 'package:template_b/feat/profile/presentation/screens/my_profile_screen.dart';
import 'package:template_b/feat/upload_ad/presentation/upload_ad_screen.dart';
import '../../../routes/app_routes.dart';

Map<String, dynamic> appRouteRgistry = {
  AppRouteConstants.home.name: HomeScreen(),
  AppRouteConstants.services.name: ServiceScreen(),
  AppRouteConstants.myProfile.name: MyProfileScreen(),
  AppRouteConstants.dashboardScreen.name: DashboardScreen(),
  AppRouteConstants.uploadAd.name: UploadAdScreen(),
  AppRouteConstants.contact.name: ContactScreen(),
  AppRouteConstants.feedback.name: FeedbackScreen(),
  AppRouteConstants.featureListing.name : ListingScreen(),
};
