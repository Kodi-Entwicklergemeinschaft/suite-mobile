import 'package:network/network.dart';
import 'parking_spot_model.dart';

class ParkingSpacesResponseModel
    extends BaseModel<ParkingSpacesResponseModel> {
  final bool success;
  final List<ParkingSpotModel> spots;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  ParkingSpacesResponseModel({
    this.success = false,
    this.spots = const [],
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  ParkingSpacesResponseModel fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List?;
    final spots = data
            ?.map((item) =>
                ParkingSpotModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ParkingSpacesResponseModel(
      success: json['success'] as bool? ?? false,
      spots: spots,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': spots.map((s) => s.toJson()).toList(),
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (path != null) 'path': path,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}
