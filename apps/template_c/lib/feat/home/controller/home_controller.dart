import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/state_constant.dart';

import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';
import 'package:template_c/feat/home/domain/usecases/get_home_config_usecase.dart';
import 'package:template_c/feat/home/state/home_state.dart';
import 'package:template_c/feat/home/widgets/home_tab_bar_widget.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  () => HomeController(),
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState(activeTab: null, components: []);
  }

  Future<void> loadHomeConfig() async {
    state = state.copyWith(configState: StateConstant.loading);
    final result = await ref
        .read(getHomeConfigUseCaseProvider)
        .call(const NoParams());
    result.fold(
      (error) {
        debugPrint('HomeController: home config error: $error');
        state = state.copyWith(configState: StateConstant.error);
      },
      (config) => state = state.copyWith(
        components: config.components,
        configState: StateConstant.success,
      ),
    );
  }

  /// Refreshes home config first, then returns (familyKey, freshFilter) pairs
  /// for all currently visible components so callers can re-fetch with the
  /// latest filter from the API — not the stale filter cached in state.
  Future<List<({String key, ListingFilterModel filter})>>
  refreshDefaultView() async {
    await loadHomeConfig();
    return state.components
        .where((c) => c.visible)
        .map(
          (c) => (
            key: ListingFamilyKey.of(c.variant, c.uniqueKey),
            filter: c.toListingFilter(),
          ),
        )
        .toList();
  }

  void selectTab(HomeTab tab) {
    if (state.activeTab == tab) {
      state = state.copyWith(clearTab: true, clearDateRange: true);
    } else {
      state = state.copyWith(activeTab: tab, clearDateRange: true);
    }
  }

  void selectDateRange(DateTimeRange range) {
    state = state.copyWith(
      activeTab: HomeTab.customDate,
      selectedDateRange: range,
    );
  }

  void clearDateSelection() {
    state = state.copyWith(clearTab: true, clearDateRange: true);
  }

  /// Refreshes all tabs — default view components, today, tomorrow, week days,
  /// and the active custom range if set.
  Future<void> refreshAll() async {
    final freshComponents = await refreshDefaultView();

    final tabKeys = <String>[
      ListingFamilyKey.heute,
      ListingFamilyKey.morgen,
      for (final day in HomeWeekDay.values) ListingFamilyKey.weekDay(day),
      if (state.selectedDateRange != null)
        ListingFamilyKey.customRange(state.selectedDateRange!),
      ...BottomNavigationController.activeListingKeys,
    ];

    await Future.wait([
      // Home components: re-fetch with fresh filter from API
      for (final entry in freshComponents)
        ref
            .read(listingControllerProvider(entry.key).notifier)
            .getListing(entry.filter),
      // Tab views: re-fetch with their own cached filter (date-driven, not API)
      for (final key in tabKeys)
        if (BottomNavigationController.activeListingKeys.contains(key))
          ref.read(listingScreenControllerProvider(key).notifier).refresh()
        else
          ref.read(listingControllerProvider(key).notifier).refresh(),
    ]);
  }
}
