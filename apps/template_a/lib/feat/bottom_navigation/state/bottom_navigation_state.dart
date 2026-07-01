import 'package:template_a/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';
import 'package:template_a/feat/bottom_navigation/model/bottom_nav_bar_model.dart';

class BottomNavigationState {
  final bool isLoading;
  final BottomNavigationResponseModel? bottomNavigationResponseModel;
  final BottomNavBarModel? bottomNavBarModel;

  const BottomNavigationState({
    this.isLoading = false,
    this.bottomNavigationResponseModel,
    this.bottomNavBarModel,
  });

  BottomNavigationState copyWith({
    bool? isLoading,
    BottomNavigationResponseModel? bottomNavigationResponseModel,
    BottomNavBarModel? bottomNavBarModel,
  }) {
    return BottomNavigationState(
      isLoading: isLoading ?? this.isLoading,
      bottomNavigationResponseModel:
          bottomNavigationResponseModel ?? this.bottomNavigationResponseModel,
      bottomNavBarModel: bottomNavBarModel ?? this.bottomNavBarModel,
    );
  }
}
