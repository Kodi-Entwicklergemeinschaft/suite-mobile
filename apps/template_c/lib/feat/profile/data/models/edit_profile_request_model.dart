import 'package:network/network.dart';

/// Model representing edit profile request body
class EditProfileRequestModel extends BaseModel<EditProfileRequestModel> {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? website;
  final String? information;

  EditProfileRequestModel({
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.website,
    this.information,
  });

  @override
  EditProfileRequestModel fromJson(Map<String, dynamic> json) {
    return EditProfileRequestModel(
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      information: json['information'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (username != null && username!.isNotEmpty) {
      json['username'] = username;
    }
    if (firstName != null && firstName!.isNotEmpty) {
      json['firstName'] = firstName;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      json['lastName'] = lastName;
    }
    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }

    if (website != null) {
      json['website'] = website;
    }
    if (information != null) {
      json['information'] = information;
    }

    return json;
  }
}
