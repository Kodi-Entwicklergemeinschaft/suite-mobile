import 'package:network/network.dart';

class MeResponseModel extends BaseModel<MeResponseModel> {
  final bool? success;
  final String? message;
  final MeData? data;

  MeResponseModel({this.success, this.message, this.data});

  @override
  MeResponseModel fromJson(Map<String, dynamic> json) {
    return MeResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? MeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class MeData {
  final String? userId;
  final String? email;
  final String? role;
  final String? tenantId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final bool? isProfileSentForVerification;
  final bool? isScrapperUser;
  final bool? onboarded;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? localityName;

  MeData({
    this.userId,
    this.email,
    this.role,
    this.tenantId,
    this.username,
    this.firstName,
    this.lastName,
    this.isProfileSentForVerification,
    this.isScrapperUser,
    this.onboarded,
    this.latitude,
    this.longitude,
    this.radius,
    this.localityName,
  });

  factory MeData.fromJson(Map<String, dynamic> json) {
    return MeData(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      tenantId: json['tenantId'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      isProfileSentForVerification:
          json['isProfileSentForVerification'] as bool?,
      isScrapperUser: json['isScrapperUser'] as bool?,
      onboarded: json['onboarded'] as bool?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radius: (json['radius'] as num?)?.toDouble(),
      localityName: json['localityName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'role': role,
        'tenantId': tenantId,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'isProfileSentForVerification': isProfileSentForVerification,
        'isScrapperUser': isScrapperUser,
        'onboarded': onboarded,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'localityName': localityName,
      };
}
