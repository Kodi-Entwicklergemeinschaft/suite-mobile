import 'package:network/network.dart';

class PostProfileDataResponseModel
    implements BaseModel<PostProfileDataResponseModel> {
  bool? success;
  ProfileUpdatedData? data;
  String? message;
  int? statusCode;

  PostProfileDataResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  PostProfileDataResponseModel fromJson(Map<String, dynamic> json) {
    return PostProfileDataResponseModel(
      success: json['success'],
      data: json['data'] != null
          ? ProfileUpdatedData.fromJson(json['data'])
          : null,
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

class ProfileUpdatedData {
  String? firstName;
  String? lastName;
  String? salutationCode;
  String? profilePhotoUrl;
  String? preferredLanguage;
  bool? hasVehicle;

  ProfileUpdatedData({
    this.firstName,
    this.lastName,
    this.salutationCode,
    this.profilePhotoUrl,
    this.preferredLanguage,
    this.hasVehicle,
  });

  factory ProfileUpdatedData.fromJson(Map<String, dynamic> json) {
    return ProfileUpdatedData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      salutationCode: json['salutationCode'],
      profilePhotoUrl: json['profilePhotoUrl'],
      preferredLanguage: json['preferredLanguage'],
      hasVehicle: json['hasVehicle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'salutationCode': salutationCode,
      'profilePhotoUrl': profilePhotoUrl,
      'preferredLanguage': preferredLanguage,
      'hasVehicle': hasVehicle,
    };
  }
}