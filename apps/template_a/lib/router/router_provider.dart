import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';
import 'package:template_a/feat/bottom_navigation/presentation/bottom_navigation_screen.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';
import 'package:template_a/feat/search/presentation/search_screen.dart';
import 'package:template_a/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_a/feat/splash/controller/splash_controller.dart';
import 'package:template_a/core/constant/nav_key.dart';
import 'package:template_a/router/app_routes.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/shell_route_registry.dart';

// ─── Shell Config Provider ────────────────────────────────────────────────────

/// Holds the parsed tab list from the API.
/// When setConfig() is called, [routerProvider] rebuilds with real shell branches.
final shellConfigProvider =
    NotifierProvider<ShellConfigNotifier, List<NavigationData>?>(
  ShellConfigNotifier.new,
);

class ShellConfigNotifier extends Notifier<List<NavigationData>?> {
  @override
  List<NavigationData>? build() => null;

  void setConfig(List<NavigationData>? tabs) => state = tabs;

  /// Path of the first tab — used for post-auth navigation.
  String get firstTabPath {
    final first = state?.firstOrNull;
    if (first == null) return RouteConstant.splash.path;
    return '/shell/${first.slug}';
  }
}

// ─── Router ───────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final tabs = ref.watch(shellConfigProvider);

  // RouterProvider reads these providers so that when shellConfigProvider
  // changes (tabs arrive), the redirect fires immediately on the new router
  // without needing any imperative navigation from splash screen.
  final splashState = ref.watch(splashControllerProvider);
  final prefManager = ref.read(preferenceManagerProvider);

  final router = GoRouter(
    navigatorKey: globalNavKey,
    initialLocation: RouteConstant.splash.path,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final hasTabs = tabs != null && tabs.isNotEmpty;
      final isShellRoute = location.startsWith('/shell/');
      final isSplashRoute = location == RouteConstant.splash.path;

      // Guard: never enter shell routes before tabs are loaded
      if (isShellRoute && !hasTabs) return RouteConstant.splash.path;

      // Once splash initialization is complete, redirect away from /splash
      if (isSplashRoute && splashState.isThemeLoaded && hasTabs) {
        final isLoggedIn = prefManager.getBool(StorageKeys.authIsLoggedIn);
        final isGuestUser = prefManager.getBool(StorageKeys.authIsGuest);
        final isOnboarded = prefManager.getBool(StorageKeys.isOnboarded);

        if (isLoggedIn || isGuestUser) {
          final isTermsAccepted = prefManager.getBool(StorageKeys.isTermsAndConditionAccepted);

          if (isGuestUser) {
            if (!isTermsAccepted) return RouteConstant.onboarding.path;
            return ref.read(shellConfigProvider.notifier).firstTabPath;
          }

          // Registered user: if already onboarded on BE, go home directly
          if (isOnboarded) return ref.read(shellConfigProvider.notifier).firstTabPath;
          // Not onboarded yet — go through terms + preferences flow
          final isPreferencesSet = prefManager.getBool(StorageKeys.isUserPreferencesSet);
          if (!isTermsAccepted || !isPreferencesSet) {
            return RouteConstant.termsConditions.path;
          }
          return ref.read(shellConfigProvider.notifier).firstTabPath;
        }
        return RouteConstant.onboarding.path;
      }

      return null;
    },
    routes: _buildRoutes(tabs),
  );

  ref.onDispose(router.dispose);
  return router;
});

// ─── Route builders ───────────────────────────────────────────────────────────

List<RouteBase> _buildRoutes(List<NavigationData>? tabs) {
  return [
    ...appRoute,
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          BottomNavigationScreen(navigationShell: navigationShell),
      branches: tabs != null && tabs.isNotEmpty
          ? tabs.map(_buildBranch).toList()
          : [_placeholderBranch()],
    ),
  ];
}

StatefulShellBranch _buildBranch(NavigationData tab) {
  final slug = tab.slug ?? '';

  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/shell/$slug',
        name: 'shell_$slug',
        builder: (context, state) => rootScreenForTab(tab),
        routes: [
          ...buildChildRoutes(tab),
          GoRoute(
            path: 'category',
            name: '${slug}_category_push',
            builder: (context, state) {
              final params = state.extra as CategoryScreenParams?;
              if (params == null) return const SizedBox.shrink();
              return CategoryScreen(params: params);
            },
          ),
          GoRoute(
            path: 'sub_service',
            name: '${slug}_sub_service',
            builder: (context, state) {
              final params = state.extra as SubServiceScreenParams?;
              if (params == null) return const SizedBox.shrink();
              return SubServiceScreen(params: params);
            },
          ),
          GoRoute(
            path: 'search',
            name: '${slug}_search',
            builder: (context, state) {
              final query = state.extra as String?;
              return SearchScreen(initialQuery: query ?? '');
            },
            routes: [
              GoRoute(
                path: 'detail',
                name: '${slug}_search_detail',
                builder: (context, state) {
                  final listing = state.extra as ListingModel?;
                  if (listing == null) return const SizedBox.shrink();
                  return ListingDetailScreen(listing: listing);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}


StatefulShellBranch _placeholderBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/shell/_loading',
        name: 'shell_loading',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}
