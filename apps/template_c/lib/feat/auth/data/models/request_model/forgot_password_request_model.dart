/// Request model for forgot password (password reset request)
class ForgotPasswordRequestModel {
  final String username;

  ForgotPasswordRequestModel({
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}
