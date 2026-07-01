import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';

class ParkingState {
  final List<ParkingSpotModel> spots;
  final StateConstant spotsState;

  const ParkingState({
    this.spots = const [],
    this.spotsState = StateConstant.loading,
  });

  bool get isLoading => spotsState == StateConstant.loading;

  ParkingState copyWith({
    List<ParkingSpotModel>? spots,
    StateConstant? spotsState,
  }) {
    return ParkingState(
      spots: spots ?? this.spots,
      spotsState: spotsState ?? this.spotsState,
    );
  }
}
