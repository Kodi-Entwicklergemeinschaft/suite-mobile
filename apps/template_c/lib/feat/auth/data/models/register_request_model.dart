/// Model representing register request body
class RegisterRequestModel {
  final String email;
  final String username;
  final String password;
  // final String firstName;
  // final String lastName;
  final String? tenantId;

  RegisterRequestModel({
    required this.email,
    required this.username,
    required this.password,
    // required this.firstName,
    // required this.lastName,
    this.tenantId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'username': username,
      'password': password,
      // 'firstName': firstName,
      // 'lastName': lastName,
    };

    // Only include tenantId if provided
    if (tenantId != null && tenantId!.isNotEmpty) {
      json['tenantId'] = tenantId;
    }

    return json;
  }
}
