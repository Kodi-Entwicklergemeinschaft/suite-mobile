import 'package:network/network.dart';

class RemoveFavResponseModel extends BaseModel<RemoveFavResponseModel> {
  final bool success;
  final String? message;

  RemoveFavResponseModel({this.success = false, this.message});

  @override
  RemoveFavResponseModel fromJson(Map<String, dynamic> json) {
    return RemoveFavResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}
