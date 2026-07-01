import 'package:network/network.dart';

class LoginResponseModel extends BaseModel<LoginResponseModel> {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? message;
  final bool? onboarded;

  LoginResponseModel({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.message,
    this.onboarded,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'message': message,
      'onboarded': onboarded,
    };
  }

  @override
  LoginResponseModel fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;
    final userMap = dataMap['user'] as Map<String, dynamic>?;
    return LoginResponseModel(
      accessToken: dataMap['accessToken'] as String?,
      refreshToken: dataMap['refreshToken'] as String?,
      expiresIn: dataMap['expiresIn'] as int?,
      message: json['message'] as String?,
      onboarded: userMap?['onboarded'] as bool?,
    );
  }
}
