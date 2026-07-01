import 'package:network/network.dart';

class RegisterResponseModel extends BaseModel<RegisterResponseModel> {
  final String? message;

  RegisterResponseModel({
    this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  RegisterResponseModel fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] as String?,
    );
  }
}
