import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/router/app_routes.dart';
import 'package:template_c/router/feature_routes.dart';
import 'package:template_c/router/route_constant.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteConstant.splash.path,
    routes: [...appRoute, ...featureRoute],
  );
});
