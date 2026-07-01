import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';
import 'package:template_a/feat/onboarding/presentation/onboarding_screen.dart';
import 'package:template_a/feat/parking/presentation/parking_screen.dart';
import 'package:template_a/feat/search/presentation/search_screen.dart';
import 'package:template_a/feat/services/presentation/service_hub_screen.dart';
import 'package:template_a/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_a/feat/splash/presentation/splash_screen.dart';
import 'package:template_a/feat/terms_conditions/presentation/terms_conditions_screen.dart';
import 'package:template_a/feat/user_preferences/presentation/user_preferences_screen.dart';
import 'package:template_a/router/route_constant.dart';

/// Routes outside StatefulShellRoute — bottom bar is hidden on all of these.
final appRoute = <GoRoute>[
  GoRoute(
    path: RouteConstant.splash.path,
    name: RouteConstant.splash.name,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: RouteConstant.onboarding.path,
    name: RouteConstant.onboarding.name,
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: RouteConstant.signin.path,
    name: RouteConstant.signin.name,
    builder: (context, state) => const OnboardingScreen(initialPage: 3),
  ),
  GoRoute(
    path: RouteConstant.search.path,
    name: RouteConstant.search.name,
    builder: (context, state) {
      final query = state.extra as String?;
      return SearchScreen(initialQuery: query ?? '');
    },
    routes: [
      GoRoute(
        path: 'detail',
        name: '${RouteConstant.search.name}_detail',
        builder: (context, state) {
          final extra = state.extra;
          ListingModel? listing;
          String? searchedText;
          if (extra is List && extra.isNotEmpty) {
            listing = extra[0] as ListingModel?;
            searchedText = extra.length > 1 ? extra[1] as String? : null;
          } else {
            listing = extra as ListingModel?;
          }
          if (listing == null) return const SizedBox.shrink();
          return ListingDetailScreen(listing: listing, searchedText: searchedText);
        },
      ),
    ],
  ),
  GoRoute(
    path: RouteConstant.termsConditions.path,
    name: RouteConstant.termsConditions.name,
    builder: (context, state) => const TermsConditionsScreen(),
  ),
  GoRoute(
    path: RouteConstant.userPreferences.path,
    name: RouteConstant.userPreferences.name,
    builder: (context, state) => const UserPreferencesScreen(),
  ),
  GoRoute(
    path: RouteConstant.parking.path,
    name: RouteConstant.parking.name,
    builder: (context, state) => const ParkingScreen(),
  ),
  GoRoute(
    path: RouteConstant.subService.path,
    name: RouteConstant.subService.name,
    builder: (context, state) {
      final params = state.extra as SubServiceScreenParams?;
      if (params == null) return const SizedBox.shrink();
      return SubServiceScreen(params: params);
    },
  ),
  GoRoute(
    path: RouteConstant.serviceHub.path,
    name: RouteConstant.serviceHub.name,
    builder: (context, state) {
      final params = state.extra as ServiceHubScreenParams?;
      return ServiceHubScreen(
        params: params ?? const ServiceHubScreenParams(tabSlug: 'service_hub'),
      );
    },
  ),
  GoRoute(
    path: RouteConstant.webView.path,
    name: RouteConstant.webView.name,
    builder: (context, state) {
      final params = state.extra as CommonWebViewWidgetParams;
      return CommonWebViewWidget(
        params: CommonWebViewWidgetParams(
          url: params.url,
          title: params.title,
          requiredShortCode: params.requiredShortCode,
          showAppBar: params.showAppBar,
          loginRequired: params.loginRequired,
          showCloseButton: true,
          appBarHeight: params.appBarHeight ?? 64,
          backgroundColor: params.backgroundColor,
          onBackPressHandle: params.onBackPressHandle,
        ),
      );
    },
  ),
];
