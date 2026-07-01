import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/widgets/common_calendar.dart';
import 'package:template_c/core/widgets/lazy_indexed_stack.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/home/widgets/home_app_bar.dart';
import 'package:template_c/feat/home/widgets/home_default_view.dart';
import 'package:template_c/feat/home/widgets/home_single_day_view.dart';
import 'package:template_c/feat/home/widgets/home_tab_bar_widget.dart';
import 'package:template_c/feat/home/widgets/home_week_view.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/profile/presentation/profile_bottom_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/router/route_constant.dart';

import '../../profile/controllers/profile_controller.dart';

class HomeScreen extends BaseStatefulWidget {
  const HomeScreen({super.key});

  @override
  String get screenName => RouteConstant.home.name;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseStatefulWidgetState<HomeScreen> {
  static const int _indexDefault = 0;
  static const int _indexToday = 1;
  static const int _indexTomorrow = 2;
  static const int _indexWeek = 3;
  static const int _indexCustom = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeControllerProvider.notifier).loadHomeConfig(),
    );
  }

  int _activeIndex(HomeTab? tab) => switch (tab) {
    HomeTab.heute => _indexToday,
    HomeTab.morgen => _indexTomorrow,
    HomeTab.dieseWoche => _indexWeek,
    HomeTab.customDate => _indexCustom,
    null => _indexDefault,
  };


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    ref.listen(profileControllerProvider, (previous, next) {});

    return Scaffold(
      appBar: HomeAppBar(
        onLocationTap: () {
          context.pushNamed(
            RouteConstant.locationOnboarding.name,
            extra: LocationOnboardingParams(
              isSkip: false,
              onConfirm: (context) {
                ref.read(homeControllerProvider.notifier).refreshAll();
                context.pop();
              },
            ),
          );
        },
        onProfileTap: () {
          showProfileBottomSheet(context);
        },
      ),
      body: Column(
        children: [
          HomeTabBarWidget(
            activeTab: state.activeTab,
            isDatepickerActive: state.activeTab == HomeTab.customDate,
            onTabSelected: controller.selectTab,
            onDatepickerTap: () async {
              if (state.activeTab == HomeTab.customDate) {
                controller.clearDateSelection();
                return;
              }
              final range = await CommonCalendar.show<DateTimeRange>(
                context,
                selectionMode: CalendarSelectionMode.range,
              );
              if (range != null) {
                controller.selectDateRange(range);
              }
            },
          ),
          Expanded(
            child: LazyIndexedStack(
              index: _activeIndex(state.activeTab),
              children: [
                HomeDefaultView(state: state),
                HomeSingleDayView.today(),
                HomeSingleDayView.tomorrow(),
                const HomeWeekView(),
                if (state.selectedDateRange != null)
                  HomeSingleDayView.customRange(state.selectedDateRange!)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
