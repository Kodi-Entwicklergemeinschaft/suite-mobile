import 'package:network/network.dart';

class GetProfileDataResponseModel
    implements BaseModel<GetProfileDataResponseModel> {
  bool? success;
  ProfileData? data;
  String? message;
  int? statusCode;

  GetProfileDataResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  GetProfileDataResponseModel fromJson(Map<String, dynamic> json) {
    return GetProfileDataResponseModel(
      success: json['success'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'statusCode': statusCode,
    };
  }
}

class ProfileData {
  String? id;
  String? email;
  String? username;
  String? role;
  String? firstName;
  String? lastName;
  String? salutationCode;
  bool? hasVehicle;
  String? profilePhotoUrl;
  String? preferredLanguage;
  String? status;
  String? createdAt;
  String? updatedAt;

  ProfileData({
    this.id,
    this.email,
    this.username,
    this.role,
    this.firstName,
    this.lastName,
    this.salutationCode,
    this.hasVehicle,
    this.profilePhotoUrl,
    this.preferredLanguage,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      salutationCode: json['salutationCode'] as String?,
      hasVehicle: json['hasVehicle'] as bool?,
      profilePhotoUrl: (json['profileIcon'] ?? json['profilePhotoUrl']) as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'salutationCode': salutationCode,
      'hasVehicle': hasVehicle,
      'profilePhotoUrl': profilePhotoUrl,
      'preferredLanguage': preferredLanguage,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}