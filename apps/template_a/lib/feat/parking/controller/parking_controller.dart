import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/parking/data/models/parking_spot_model.dart';
import 'package:template_a/feat/parking/domain/usecases/get_parking_spaces_usecase.dart';
import 'package:template_a/feat/parking/state/parking_state.dart';

const _dummySpots = [
  ParkingSpotModel(
    id: 'dummy-1',
    parkingSiteId: 'site-1',
    name: 'Car Park A',
    lat: 51.5074,
    lng: -0.1278,
    totalSlots: 120,
    availableSlots: 45,
    occupiedSlots: 75,
  ),
  ParkingSpotModel(
    id: 'dummy-2',
    parkingSiteId: 'site-2',
    name: 'Car Park B',
    lat: 51.5080,
    lng: -0.1290,
    totalSlots: 80,
    availableSlots: 12,
    occupiedSlots: 68,
  ),
  ParkingSpotModel(
    id: 'dummy-3',
    parkingSiteId: 'site-3',
    name: 'Car Park C',
    lat: 51.5065,
    lng: -0.1260,
    totalSlots: 200,
    availableSlots: 150,
    occupiedSlots: 50,
  ),
];

final parkingControllerProvider =
    NotifierProvider<ParkingController, ParkingState>(
  () => ParkingController(),
);

class ParkingController extends Notifier<ParkingState> {
  @override
  ParkingState build() {
    return const ParkingState();
  }

  Future<void> loadParkingSpaces() async {
    state = state.copyWith(spotsState: StateConstant.loading);
    final result = await ref
        .read(getParkingSpacesUseCaseProvider)
        .call(const NoParams());
    result.fold(
      (error) {
        debugPrint('ParkingController: error loading parking spaces: $error');
        state = state.copyWith(spotsState: StateConstant.error);
      },
      (spots) {
        state = state.copyWith(
          spots: spots.isEmpty ? _dummySpots : spots,
          spotsState: StateConstant.success,
        );
      },
    );
  }

  Future<void> refresh() async {
    await loadParkingSpaces();
  }
}
