import 'package:flutter/material.dart';
import 'package:template_c/offline/offline_bottom_nav/presentation/offline_nav_item.dart';

class OfflineBottomNavState {
  final int selectedIndex;
  final List<Widget> screenList;
  final List<OfflineNavItem> navItems;

  const OfflineBottomNavState({
    required this.selectedIndex,
    required this.screenList,
    required this.navItems,
  });

  OfflineBottomNavState copyWith({
    int? selectedIndex,
    List<Widget>? screenList,
    List<OfflineNavItem>? navItems,
  }) {
    return OfflineBottomNavState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      screenList: screenList ?? this.screenList,
      navItems: navItems ?? this.navItems,
    );
  }
}