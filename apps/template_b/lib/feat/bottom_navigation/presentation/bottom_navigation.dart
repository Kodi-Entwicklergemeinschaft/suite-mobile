import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/constants/action_constant.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/profile/presentation/widgets/profile_logout_listener.dart';
import 'dynamic_bottom_nav_bar.dart';

class BottomNavigation extends BaseStatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  String get screenName => AppRouteConstants.bottomNavigation.name;

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends BaseStatefulWidgetState<BottomNavigation>
    with WidgetsBindingObserver {
  late GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(bottomNavigationProvider.notifier).loadConfig());
    scaffoldKey = GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final controller = ref.read(bottomNavigationProvider.notifier);
    if (lifecycleState == AppLifecycleState.paused) {
      // Remove native WKWebView instances from the widget tree so Flutter's
      // Pigeon InstanceManager releases them before the engine shuts down.
      // Without this, force-quit crashes in WebKitLibraryPigeonInternalFinalizer.
      controller.clearWebViewScreens();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      controller.restoreScreens();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavigationState = ref.watch(bottomNavigationProvider);
    final bottomNavigationController = ref.read(
      bottomNavigationProvider.notifier,
    );

    ref.listen(authStateProvider, (previous, next) {
      if (previous == true && next == false) {
        bottomNavigationController.deactivateWebViewScreens(clearActive: true);
      }
    });

    return LogoutListener(
      child: PopScope(
        canPop: bottomNavigationState.selectedIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            bottomNavigationController.setSelectedIndex(0);
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          body: (bottomNavigationState.isLoading)
              ? CommonCircularProgessIndicator()
              : (bottomNavigationState
                        .bottomNavigationConfigResponseModel
                        ?.data ==
                    null)
              ? Center(child: CommonText(titleText: 'no_configuration'.tr))
              : IndexedStack(
                  key: bottomNavigationState.indexedStackKey,
                  index: bottomNavigationState.selectedIndex,
                  children: bottomNavigationState.screen.cast<Widget>(),
                ),
          bottomNavigationBar:
              (bottomNavigationState
                      .bottomNavigationConfigResponseModel
                      ?.data ==
                  null)
              ? null
              : DynamicBottomNavBar(
                  config: bottomNavigationState.bottomNavBarModel!,
                  onNavItemTapped: (index) {
                    executeOnTap(
                      index,
                      bottomNavigationState,
                      bottomNavigationController,
                    );
                  },
                  currentIndex: bottomNavigationState.selectedIndex,
                ),
        ),
      ),
    );
  }

  executeOnTap(
    int index,
    bottomNavigationState,
    bottomNavigationController,
  ) async {
    final data = bottomNavigationState
        .bottomNavigationConfigResponseModel!
        .data![index]
        .action;
    if (bottomNavigationState
            .bottomNavigationConfigResponseModel!
            .data![index]
            .action!
            .type ==
        ActionConstant.urlBrowser.name) {
      ref.read(templateBHandlerProvider).executeAction(context, data!);
    } else if (bottomNavigationState
            .bottomNavigationConfigResponseModel!
            .data![index]
            .action!
            .type ==
        ActionConstant.urlWebview.name) {
      if (data.config?.requireLogin != null &&
          data.config?.requireLogin == true) {
        final isLoggedIn = ref.read(authStateProvider);
        if (!isLoggedIn) {
          bottomNavigationController.setSelectedIndex(index);
          return;
        }
      }
      bottomNavigationController.activateWebViewScreen(index);
      bottomNavigationController.setSelectedIndex(index);
    } else {
      bottomNavigationController.setSelectedIndex(index);
    }
  }
}
