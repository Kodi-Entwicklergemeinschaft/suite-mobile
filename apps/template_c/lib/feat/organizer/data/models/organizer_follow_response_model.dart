import 'package:network/network.dart';

class OrganizerFollowResponseModel extends BaseModel<OrganizerFollowResponseModel> {
  final bool success;
  final String? message;

  OrganizerFollowResponseModel({this.success = false, this.message});

  @override
  OrganizerFollowResponseModel fromJson(Map<String, dynamic> json) {
    return OrganizerFollowResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'success': success,
        if (message != null) 'message': message,
      };
}
