import 'package:network/network.dart';

class LocationPreferenceResponseModel
    extends BaseModel<LocationPreferenceResponseModel> {
  final bool? success;
  final String? message;

  LocationPreferenceResponseModel({this.success, this.message});

  @override
  LocationPreferenceResponseModel fromJson(Map<String, dynamic> json) {
    return LocationPreferenceResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}
