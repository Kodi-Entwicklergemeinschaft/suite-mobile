import 'package:latlong2/latlong.dart';
import 'package:template_c/feat/open_street_map/state/map_with_radius_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapWithRadiusProvider =
    NotifierProvider.autoDispose<MapWithRadiusController, MapWithRadiusState>(
      () => MapWithRadiusController(),
    );

class MapWithRadiusController extends Notifier<MapWithRadiusState> {
  @override
  MapWithRadiusState build() {
    return MapWithRadiusState(4.0);
  }

  void setRadiusKm(double radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
  }
}
