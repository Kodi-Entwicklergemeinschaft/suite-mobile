/// Model representing login request body
/// username can be either username or email
class LoginRequestModel {
  final String usernameOrEmail;
  final String password;
  final String deviceId;

  LoginRequestModel({required this.usernameOrEmail, required this.password,required this.deviceId});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'username': usernameOrEmail,
      'password': password,
      'deviceId':deviceId
    };
    return json;
  }
}
