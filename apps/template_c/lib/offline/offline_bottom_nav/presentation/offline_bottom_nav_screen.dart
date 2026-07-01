import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/offline/offline_bottom_nav/controller/offline_bottom_nav_controller.dart';
import 'package:template_c/offline/offline_bottom_nav/presentation/offline_dynamic_bottom_navigation.dart';

class OfflineBottomNavScreen extends BaseStatelessWidget {
  const OfflineBottomNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offlineBottomNavControllerProvider);

    return PopScope(
      canPop: state.selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: state.selectedIndex,
          children: state.screenList,
        ),
        bottomNavigationBar: OfflineDynamicBottomNavBar(
          screenList: state.screenList,
          navItems: state.navItems,
          selectedIndex: state.selectedIndex,
        ),
      ),
    );
  }
}
