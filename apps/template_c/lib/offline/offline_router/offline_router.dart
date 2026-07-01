import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/offline/fav_offline/presentation/fav_offline_screen.dart';
import 'package:template_c/offline/offline_bottom_nav/presentation/offline_bottom_nav_screen.dart';
import 'package:template_c/offline/offline_router/offline_route_constant.dart';

final connectivityRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: OfflineRouteConstant.offlineBottomConfig.path,
    routes: [
      GoRoute(
        path: OfflineRouteConstant.favOfflineScreen.path,
        name: OfflineRouteConstant.favOfflineScreen.name,
        builder: (context, state) => const FavOfflineScreen(),
      ),

      GoRoute(
        path: OfflineRouteConstant.offlineBottomConfig.path,
        name: OfflineRouteConstant.offlineBottomConfig.name,
        builder: (context, state) => const OfflineBottomNavScreen(),
      ),
    ],
  );
});
