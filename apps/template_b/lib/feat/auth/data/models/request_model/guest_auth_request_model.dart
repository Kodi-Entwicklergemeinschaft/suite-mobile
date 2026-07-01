/// Request model for guest authentication
class GuestAuthRequestModel {
  final String deviceId;

  GuestAuthRequestModel({required this.deviceId});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
      };
}
