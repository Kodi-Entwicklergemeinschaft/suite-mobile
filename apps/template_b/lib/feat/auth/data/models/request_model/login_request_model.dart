/// Model representing login request body
/// username can be either username or email
class LoginRequestModel {
  final String username;
  final String password;
  final String deviceId;

  LoginRequestModel({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'username': username,
      'password': password,
      'deviceId': deviceId,
    };
    return json;
  }
}
