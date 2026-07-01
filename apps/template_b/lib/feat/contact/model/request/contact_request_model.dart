import 'package:network/network.dart';

class ContactRequestModel implements BaseModel<ContactRequestModel> {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? message;

  ContactRequestModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.message,
  });

  @override
  ContactRequestModel fromJson(Map<String, dynamic> json) {
    return ContactRequestModel(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'message': message,
    };
  }
}