import 'package:template_c/offline/offline_bottom_nav/registry/offline_app_route_registry.dart';
import 'package:template_c/offline/offline_bottom_nav/registry/offline_feature_route_registry.dart';

final offlineBottomNavRegistry = {
  ...offlineAppRouteRegistry,
  ...offlineFeatureRouteRegistry,
};
