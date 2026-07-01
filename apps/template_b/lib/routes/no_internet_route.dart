import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_b/feat/connectivity/presentation/connectivity_screen.dart';

final connectivityRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ConnectivityScreen(),
      ),
    ],
  );
});
