import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/action_constant.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_a/feat/bottom_navigation/presentation/dynamic_bottom_nav_bar.dart';
import 'package:template_a/feat/bottom_navigation/state/bottom_navigation_state.dart';
import 'package:template_a/feat/home/controller/home_controller.dart';
import 'package:template_a/feat/home/widgets/hamburger_menu_drawer.dart';
import 'package:template_a/feat/category/controller/category_screen_controller.dart';
import 'package:template_a/feat/filter/controller/date_filter_controller.dart';
import 'package:template_a/feat/filter/controller/quick_filter_controller.dart';
import 'package:template_a/feat/services/presentation/controller/service_controller.dart';
import 'package:template_a/router/route_constant.dart';

final drawerScaffoldKey = GlobalKey<ScaffoldState>();

class BottomNavigationScreen extends BaseStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationScreen({required this.navigationShell, super.key});

  @override
  String get screenName => 'bottom_navigation';

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends BaseStatefulWidgetState<BottomNavigationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask((){
       ref.read(bottomNavigationProvider.notifier).registerFcmToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bottomNavigationProvider);

    if (state.isLoading) {
      return Scaffold(body: CommonCircularProgessIndicator());
    }

    final hasData =
        state.bottomNavigationResponseModel?.data != null &&
        state.bottomNavigationResponseModel!.data!.isNotEmpty;

    if (!hasData) {
      return Scaffold(
        body: Center(child: CommonText(titleText: 'No Configuration Found')),
      );
    }

    return PopScope(
      canPop: widget.navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            final currentIndex = widget.navigationShell.currentIndex;
            _clearFiltersForTabIndex(currentIndex, state);
            widget.navigationShell.goBranch(0);
          }
        }
      },
      child: Scaffold(
        key: drawerScaffoldKey,
        drawer: HamburgerMenuDrawer(navigationShell: widget.navigationShell),
        drawerEnableOpenDragGesture: false,
        body: widget.navigationShell,
        bottomNavigationBar: DynamicBottomNavBar(
          config: state.bottomNavBarModel!,
          onNavItemTapped: (index) => _onTabTap(context, index, state),
          currentIndex: widget.navigationShell.currentIndex,
        ),
      ),
    );
  }

  void _clearFiltersForTabIndex(int tabIndex, BottomNavigationState state) {
    final tabData = state.bottomNavigationResponseModel?.data?[tabIndex];
    final category = tabData?.action?.config?.category;
    if (category != null && category.isNotEmpty) {
      ref.read(categoryScreenControllerProvider(category).notifier).clearFilter();
      ref.read(quickFilterControllerProvider(category).notifier).resetFilters();
      ref.read(dateFilterControllerProvider.notifier).reset();
    }
  }

  Future<void> _onTabTap(
    BuildContext context,
    int index,
    BottomNavigationState state,
  ) async {
    final data = state.bottomNavigationResponseModel!.data![index];
    final actionType = data.action?.type;
    final actionConfig = data.action?.config;

    // External URL — open in browser, do NOT switch tab
    if (actionType == ActionConstant.urlBrowser.name) {
      final url = actionConfig?.url ?? '';
      if (url.isNotEmpty) {
        ref.read(launcherHandler).executeAction(
          context,
          url,
          shortCodeRequired: actionConfig?.requiredShortCode ?? false,
        );
      }
      return;
    }

    // WebView — login check then push as a modal screen, do NOT switch tab
    if (actionType == ActionConstant.urlWebview.name) {
      final url = actionConfig?.url ?? '';
      if (url.isEmpty) return;

      if (actionConfig?.requireLogin == true) {
        final isLoggedIn = ref.read(authStateProvider);
        if (!isLoggedIn) {
          await CommonSheet.showConfirmation(
            context,
            title: 'sign_in'.tr,
            content: 'please_login_to_continue'.tr,
            confirmButtonText: 'sign_in'.tr,
            cancelButtonText: 'cancel'.tr,
            onConfirm: () {
              if (context.mounted) {
                context.pushNamed(RouteConstant.signin.name);
              }
            },
          );
          return;
        }
      }

      if (context.mounted) {
        context.pushNamed(
          RouteConstant.webView.name,
          extra: CommonWebViewWidgetParams(
            url: url,
            title: data.label ?? '',
            requiredShortCode: actionConfig?.requiredShortCode ?? false,
            showCloseButton: true,
            appBarHeight: 64,
          ),
        );
      }
      return;
    }

    final previousIndex = widget.navigationShell.currentIndex;

    // Reset filters when leaving a category-type tab
    if (previousIndex != index) {
      _clearFiltersForTabIndex(previousIndex, state);
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == previousIndex,
    );

    final homeTabIndex = _homeTabIndex(state);
    if (homeTabIndex != null && index == homeTabIndex) {
      ref.invalidate(homeControllerProvider);
      Future.microtask(
        () => ref.read(homeControllerProvider.notifier).loadHomeConfig(),
      );
    }

    final discoverTabIndex = _discoverTabIndex(state);
    if (discoverTabIndex != null && index == discoverTabIndex) {
      Future.microtask(
        () => ref
            .read(serviceControllerProvider('discover_screen').notifier)
            .fetchServices(limit: 20),
      );
    }
  }

  int? _homeTabIndex(BottomNavigationState state) {
    final data = state.bottomNavigationResponseModel?.data;
    if (data == null) return null;
    for (int i = 0; i < data.length; i++) {
      if (data[i].action?.target == 'experience') return i;
    }
    return null;
  }

  int? _discoverTabIndex(BottomNavigationState state) {
    final data = state.bottomNavigationResponseModel?.data;
    if (data == null) return null;
    for (int i = 0; i < data.length; i++) {
      if (data[i].action?.target == 'discover') return i;
    }
    return null;
  }
}
