import 'package:flutter/material.dart';
import 'package:template_a/feat/discover/presentation/discover_screen.dart';
import 'package:template_a/feat/home/presentation/home_screen.dart';
import 'package:template_a/feat/profile/presentation/profile_screen.dart';
import 'package:template_a/feat/services/presentation/service_hub_screen.dart';

Map<String, Widget Function(String slug)> appRouteRegistry = {
  'experience': (slug) => HomeScreen(tabSlug: slug),
  'discover': (slug) => DiscoverScreen(tabSlug: slug),
  'profile': (slug) => ProfileScreen(tabSlug: slug),
  'service_hub': (slug) => ServiceHubScreen(
        params: ServiceHubScreenParams(tabSlug: slug),
      ),
};
