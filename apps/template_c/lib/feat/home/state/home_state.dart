import 'package:flutter/material.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/home/data/models/home_config.dart';
import 'package:template_c/feat/home/widgets/home_tab_bar_widget.dart';

class HomeState {
  final HomeTab? activeTab;
  final List<ContentSliderConfig> components;
  final DateTimeRange? selectedDateRange;
  final StateConstant configState;

  const HomeState({
    required this.activeTab,
    this.components = const [],
    this.selectedDateRange,
    this.configState = StateConstant.loading,
  });

  bool get isConfigLoading => configState == StateConstant.loading;

  HomeState copyWith({
    HomeTab? activeTab,
    bool clearTab = false,
    List<ContentSliderConfig>? components,
    DateTimeRange? selectedDateRange,
    bool clearDateRange = false,
    StateConstant? configState,
  }) {
    return HomeState(
      activeTab: clearTab ? null : (activeTab ?? this.activeTab),
      components: components ?? this.components,
      selectedDateRange: clearDateRange ? null : (selectedDateRange ?? this.selectedDateRange),
      configState: configState ?? this.configState,
    );
  }
}
