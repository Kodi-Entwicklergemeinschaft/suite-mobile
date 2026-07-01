import 'package:latlong2/latlong.dart';

class MapWithRadiusState {
  double radiusKm;
 
  MapWithRadiusState(this.radiusKm);

  MapWithRadiusState copyWith({double? radiusKm, LatLng? selectedLatLng,double? zoom}) {
    return MapWithRadiusState(
      radiusKm ?? this.radiusKm,
      
    );
  }
}
