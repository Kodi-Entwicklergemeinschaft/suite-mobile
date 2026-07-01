import 'package:network/network.dart';

class AddFavResponseModel extends BaseModel<AddFavResponseModel> {
  final bool success;
  final String? message;

  AddFavResponseModel({this.success = false, this.message});

  @override
  AddFavResponseModel fromJson(Map<String, dynamic> json) {
    return AddFavResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}
