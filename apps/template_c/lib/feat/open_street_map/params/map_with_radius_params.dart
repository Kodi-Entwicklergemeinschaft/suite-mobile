import 'package:latlong2/latlong.dart';

class MapWithRadiusParams {
  double height;
  double width;
  LatLng selectedLatLong;
  double initialRadiusKm;
  void Function(double radiusKm)? onRadiusChanged;
  String? userName;

  MapWithRadiusParams({
    required this.height,
    required this.width,
    required this.selectedLatLong,
    this.initialRadiusKm =4.0,
    this.onRadiusChanged,
    this.userName,
  });
}
