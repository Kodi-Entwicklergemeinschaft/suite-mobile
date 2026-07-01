import 'package:network/network.dart';

class ForgotPasswordResponseModel extends BaseModel<ForgotPasswordResponseModel> {
  final String? message;

  ForgotPasswordResponseModel({
    this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  ForgotPasswordResponseModel fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: json['message'] as String?,
    );
  }
}
