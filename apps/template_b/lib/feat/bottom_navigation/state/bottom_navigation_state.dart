import 'package:flutter/material.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';
import 'package:template_b/feat/bottom_navigation/model/ui_model/bottom_nav_bar_model.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';

class BottomNavigationState {
  final bool isLoading;
  BottomNavigationConfigResponseModel? bottomNavigationConfigResponseModel;
  final int selectedIndex;
  List<Widget> screen;
  BottomNavBarModel? bottomNavBarModel;
  final Key indexedStackKey;

  BottomNavigationState(
    this.isLoading,
    this.selectedIndex,
    this.bottomNavigationConfigResponseModel,
    this.screen,
    this.bottomNavBarModel, {
    Key? indexedStackKey,
  }) : indexedStackKey = indexedStackKey ?? UniqueKey();

  BottomNavigationState copyWith({
    bool? isLoading,
    int? selectedIndex,
    BottomNavigationConfigResponseModel? bottomNavigationConfigResponseModel,
    List<Widget>? screen,
    BottomNavBarModel? bottomNavBarModel,
    Key? indexedStackKey,
  }) {
    return BottomNavigationState(
      isLoading ?? this.isLoading,
      selectedIndex ?? this.selectedIndex,
      bottomNavigationConfigResponseModel ??
          this.bottomNavigationConfigResponseModel,
      screen ?? this.screen,
      bottomNavBarModel ?? this.bottomNavBarModel,
      indexedStackKey: indexedStackKey ?? this.indexedStackKey,
    );
  }
}
