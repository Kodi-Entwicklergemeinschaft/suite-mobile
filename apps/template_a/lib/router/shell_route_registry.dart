import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:template_a/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';
import 'package:template_a/feat/bottom_navigation/registry/app_route_registry.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/params/listing_screen_params.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';
import 'package:template_a/feat/listing/presentation/listing_screen.dart';
import 'package:template_a/feat/parking/presentation/parking_screen.dart';
import 'package:template_a/feat/services/presentation/service_hub_screen.dart';
import 'package:template_a/feat/user/profile/presentation/profile_edit_screen.dart';
import 'package:template_a/feat/user/settings/presentation/reset_password_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_language_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_theme_screen.dart';
import 'package:template_a/feat/user/settings/presentation/notification_prefs_screen.dart';
import 'package:template_a/feat/user/settings/presentation/settings_screen.dart';

// ─── Tab Root Screen Resolution ───────────────────────────────────────────────
//
// action.type == "feature"  → looked up in appRouteRegistry by action.target
// action.type == "category" → CategoryScreen built from action.config.category
//
// To add a new feature-type tab: add one entry to app_route_registry.dart.

Widget rootScreenForTab(NavigationData tab) {
  final slug = tab.slug ?? '';
  final actionType = tab.action?.type ?? '';
  final target = tab.action?.target ?? '';
  final category = tab.action?.config?.category;

  // url_webview — embed the WebView directly as the tab screen
  if (actionType == 'url_webview') {
    final url = tab.action?.config?.url ?? '';
    return CommonWebViewWidget(
      params: CommonWebViewWidgetParams(
        url: url,
        title: tab.label ?? '',
        requiredShortCode: tab.action?.config?.requiredShortCode ?? false,
        showCloseButton: true,
        appBarHeight: 64,
      ),
    );
  }

  // url_browser — launch in external browser immediately, same as on-tap behaviour
  if (actionType == 'url_browser') {
    final url = tab.action?.config?.url ?? '';
    return _ExternalBrowserScreen(url: url);
  }

  if (actionType == 'category' && category != null) {
    return CategoryScreen(
      params: CategoryScreenParams(
        categorySlug: category,
        screenTitle: tab.label ?? target,
        isEventCategory: category == 'events',
      ),
    );
  }

  final builder = appRouteRegistry[target];
  if (builder != null) return builder(slug);
  return _PlaceholderScreen(title: tab.label ?? target);
}

// ─── Child Sub-Route Registry ─────────────────────────────────────────────────
//
// Maps child slug from API children[] to a GoRoute builder.
// This lives here (not in feature_route_registry.dart) so the build script
// never overwrites it — feature_route_registry.dart is auto-generated and empty.
//
// ADD A NEW ENTRY HERE when BE adds a new child slug.
final Map<String, GoRoute Function(String path, String name)> childRouteRegistry = {
  'listing': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) {
      final params = state.extra as ListingScreenParams?;
      if (params == null) return const SizedBox.shrink();
      return ListingScreen(params: params);
    },
    routes: [
      GoRoute(
        path: 'detail',
        name: '${name}_detail',
        builder: (context, state) {
          final listing = state.extra as ListingModel?;
          if (listing == null) return const SizedBox.shrink();
          return ListingDetailScreen(listing: listing);
        },
      ),
    ],
  ),

  'events_detail': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) {
      final params = state.extra as ListingScreenParams?;
      if (params == null) return const SizedBox.shrink();
      return ListingScreen(params: params);
    },
  ),

  'user_profile_edit': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const ProfileEditScreen(),
  ),

  'user_settings': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'language',
        name: '${name}_language',
        builder: (context, state) => const SelectLanguageScreen(),
      ),
      GoRoute(
        path: 'theme',
        name: '${name}_theme',
        builder: (context, state) => const SelectThemeScreen(),
      ),
      GoRoute(
        path: 'reset_password',
        name: '${name}_reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: 'notifications',
        name: '${name}_notifications',
        builder: (context, state) => const NotificationPrefsScreen(),
      ),
    ],
  ),

  'parking': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const ParkingScreen(),
  ),

  'service_hub': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) {
      final params = state.extra as ServiceHubScreenParams?;
      return ServiceHubScreen(
        params: params ?? ServiceHubScreenParams(tabSlug: name),
      );
    },
  ),

  'mobility': (path, name) => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const _PlaceholderScreen(title: 'Mobility'),
  ),
};

List<GoRoute> buildChildRoutes(NavigationData tab) {
  final children = tab.children;
  if (children == null || children.isEmpty) return [];

  final parentSlug = tab.slug ?? '';
  final routes = <GoRoute>[];

  for (final child in children) {
    final builder = childRouteRegistry[child.slug];
    if (builder == null) continue;

    final relativePath = child.route.split('/').last;
    final routeName = '${parentSlug}_${child.slug}';
    routes.add(builder(relativePath, routeName));
  }

  return routes;
}

// Launches the URL in external browser immediately on first render —
// same behaviour as _onTabTap for url_browser tabs.
class _ExternalBrowserScreen extends StatefulWidget {
  final String url;

  const _ExternalBrowserScreen({required this.url});

  @override
  State<_ExternalBrowserScreen> createState() => _ExternalBrowserScreenState();
}

class _ExternalBrowserScreenState extends State<_ExternalBrowserScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final uri = Uri.tryParse(widget.url);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — coming soon')),
    );
  }
}
