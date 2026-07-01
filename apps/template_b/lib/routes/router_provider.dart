import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/routes/feature_routes.dart';

/// Active navigator key — reassigned each time [goRouterProvider] rebuilds so
/// `navigatorKey.currentContext` always points to the current navigator.
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The app's router. Invalidate this provider (`ref.invalidate(goRouterProvider)`)
/// to restart the entire flow from splash — e.g. on session expiry.
final goRouterProvider = Provider<GoRouter>((ref) {
  debugPrint('[AppRouter] creating new GoRouter');
  navigatorKey = GlobalKey<NavigatorState>();

  ref.onDispose(() => debugPrint('[AppRouter] GoRouter disposed'));

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRouteConstants.splash.path,
    routes: [...appRoute, ...featureRoute],
  );
});
