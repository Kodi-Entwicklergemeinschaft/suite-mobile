import 'package:flutter/material.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/bottom_navigation/model/bottom_nav_item_model.dart';

class BottomNavigationState {
  int selectedIndex;
  List<BottomNavItemModel> listOfNavItems;
  List<Widget> screenList;
  StateConstant stateConstant;
  BottomNavigationState(
    this.selectedIndex,
    this.listOfNavItems,
    this.screenList,
    this.stateConstant,
  );

  BottomNavigationState copyWith({
    int? selectedIndex,
    List<BottomNavItemModel>? listOfNavItems,
    List<Widget>? screenList,
    StateConstant? stateConstant,
  }) {
    return BottomNavigationState(
      selectedIndex ?? this.selectedIndex,
      listOfNavItems ?? this.listOfNavItems,
      screenList ?? this.screenList,
      stateConstant ?? this.stateConstant,
    );
  }
}
