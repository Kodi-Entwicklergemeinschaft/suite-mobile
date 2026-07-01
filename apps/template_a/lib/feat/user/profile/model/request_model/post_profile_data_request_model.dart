import 'package:network/network.dart';

class PostProfileDataRequestModel
    implements BaseModel<PostProfileDataRequestModel> {
  String? firstName;
  String? lastName;
  String? salutationCode;
  String? profilePhotoUrl;
  String? preferredLanguage;
  bool? hasVehicle;

  PostProfileDataRequestModel({
    this.firstName,
    this.lastName,
    this.salutationCode,
    this.profilePhotoUrl,
    this.preferredLanguage,
    this.hasVehicle,
  });

  @override
  PostProfileDataRequestModel fromJson(Map<String, dynamic> json) {
    return PostProfileDataRequestModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      salutationCode: json['salutationCode'],
      profilePhotoUrl: json['profilePhotoUrl'],
      preferredLanguage: json['preferredLanguage'],
      hasVehicle: json['hasVehicle'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (salutationCode != null) 'salutationCode': salutationCode,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (hasVehicle != null) 'hasVehicle': hasVehicle,
    };
  }
}