import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/offline/core/box_constant.dart';
import 'package:preference_manager/hive_service.dart';
import 'package:template_c/offline/offline_bottom_nav/presentation/offline_nav_item.dart';
import 'package:template_c/offline/offline_bottom_nav/registry/offline_bottom_nav_registry.dart';
import 'package:template_c/offline/offline_bottom_nav/state/offline_bottom_nav_state.dart';
import 'package:template_c/offline/offline_router/offline_route_constant.dart';

final offlineBottomNavControllerProvider =
    NotifierProvider.autoDispose<
      OfflineBottomNavController,
      OfflineBottomNavState
    >(() => OfflineBottomNavController());

class OfflineBottomNavController extends Notifier<OfflineBottomNavState> {
  // Built-in app tabs. Feature tabs from [offlineFeatureRouteRegistry] are
  // appended after these.
  static final List<OfflineNavItem> _appNavItems = [
    OfflineNavItem(
      key: OfflineRouteConstant.favOfflineScreen.name,
      icon: Icons.favorite_border,
      label: 'Favourites',
    ),
  ];

  // Fallback icon + label per known feature slug used when no cached iconUrl
  // is available (e.g. fresh install that never went online).
  static const Map<String, OfflineNavItem> _featureNavItems = {
    'waste-calendar': OfflineNavItem(
      key: 'waste-calendar',
      icon: Icons.delete_outline,
      label: 'Waste Calendar',
    ),
  };

  @override
  OfflineBottomNavState build() {
    final initial = _buildState(cachedUrls: const {});
    // Kick off async icon-URL load; updates state once Hive returns.
    Future.microtask(_loadCachedIcons);
    return initial;
  }

  Future<void> _loadCachedIcons() async {
    try {
      final raw = await HiveService.instance.get<dynamic>(
        BoxKey.templateC.name,
        BoxItemKeyConstant.bottomNavConfigKey.name,
      );
      if (raw is! List) return;
      final cachedUrls = <String, String>{};
      for (final entry in raw) {
        if (entry is Map) {
          final slug = entry['slug']?.toString();
          final url = entry['iconUrl']?.toString();
          if (slug != null && slug.isNotEmpty && url != null && url.isNotEmpty) {
            cachedUrls[slug] = url;
          }
        }
      }
      if (cachedUrls.isEmpty) return;
      state = _buildState(cachedUrls: cachedUrls)
          .copyWith(selectedIndex: state.selectedIndex);
    } catch (e) {
      debugPrint('offline nav: _loadCachedIcons error → $e');
    }
  }

  OfflineBottomNavState _buildState({
    required Map<String, String> cachedUrls,
  }) {
    final appItems = _appNavItems
        .where((item) => offlineBottomNavRegistry.containsKey(item.key))
        .map((item) => OfflineNavItem(
              key: item.key,
              label: item.label,
              icon: item.icon,
              iconUrl: cachedUrls[item.key],
            ))
        .toList();

    final featureItems = offlineBottomNavRegistry.keys
        .where((k) => !_appNavItems.any((i) => i.key == k))
        .map((slug) {
          final fallback = _featureNavItems[slug] ??
              OfflineNavItem(key: slug, icon: Icons.extension, label: slug);
          return OfflineNavItem(
            key: slug,
            label: fallback.label,
            icon: fallback.icon,
            iconUrl: cachedUrls[slug],
          );
        })
        .toList();

    final navItems = [...appItems, ...featureItems];

    final screenList = navItems
        .map((item) => offlineBottomNavRegistry[item.key] as Widget)
        .toList();

    return OfflineBottomNavState(
      selectedIndex: 0,
      screenList: screenList,
      navItems: navItems,
    );
  }

  void updateSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}
