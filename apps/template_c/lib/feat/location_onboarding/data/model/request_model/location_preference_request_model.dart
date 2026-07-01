import 'package:network/network.dart';

class LocationPreferenceRequestModel
    extends BaseModel<LocationPreferenceRequestModel> {
  final double latitude;
  final double longitude;
  final double radius;
  final String localityName;

  LocationPreferenceRequestModel({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.localityName,
  });

  @override
  LocationPreferenceRequestModel fromJson(Map<String, dynamic> json) {
    return LocationPreferenceRequestModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      localityName: json['localityName'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'localityName': localityName,
    };
  }
}
