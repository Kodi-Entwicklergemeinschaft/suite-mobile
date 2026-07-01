import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/providers/auth_state_provider.dart';
import 'package:template_c/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_c/feat/bottom_navigation/presentation/dynamic_bottom_navigation.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_constant.dart';

class BottomNavigationScreen extends BaseStatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  String get screenName => RouteConstant.bottomNav.name;

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends BaseStatefulWidgetState<BottomNavigationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final controller = ref.read(bottomNavigationControllerProvider.notifier);
    Future.microtask(() {
      controller.fetchMe();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final controller = ref.read(bottomNavigationControllerProvider.notifier);
    if (lifecycleState == AppLifecycleState.paused) {
      controller.clearWebViewScreens();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      controller.restoreScreens();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bottomNavigationControllerProvider);
    final controller = ref.read(bottomNavigationControllerProvider.notifier);

    ref.listen(authStateProvider, (previous, next) {
      if (previous == true && next == false) {
        controller.deactivateWebViewScreens(clearActive: true);
      }
    });

    ref.listen(profileControllerProvider, (previous, next) {
      if (previous != next) {
        if (next.state == StateEnum.unauthorize) {
          context.goNamed(RouteConstant.onboarding.name);
        }
      }
    });

    if (state.stateConstant == StateConstant.loading) {
      return Scaffold(body: CommonCircularProgessIndicator());
    }

    if (state.stateConstant == StateConstant.error) {
      return Scaffold(
        body: Center(child: CommonText(titleText: 'No Configuration Found')),
      );
    }

    if (state.stateConstant == StateConstant.success &&
        state.screenList.isEmpty) {
      return Scaffold(
        body: Center(child: CommonText(titleText: 'No Configuration Found')),
      );
    }

    return PopScope(
      canPop: state.selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.updateSelectedIndex(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: state.selectedIndex,
          children: state.screenList,
        ),
        bottomNavigationBar: DynamicBottomNavBar(
          screenList: state.screenList,
          listOfNavItems: state.listOfNavItems,
          selectedIndex: state.selectedIndex,
        ),
      ),
    );
  }
}
