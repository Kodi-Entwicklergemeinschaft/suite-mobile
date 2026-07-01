/// Request model for guest user registration
class GuestRegisterRequestModel {
  final String guestUserId;
  final String email;
  final String password;
  final String username;
  final String firstName;
  final String lastName;
  final String tenantId;

  GuestRegisterRequestModel({
    required this.guestUserId,
    required this.email,
    required this.password,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.tenantId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() => {
        'guestUserId': guestUserId,
        'email': email,
        'password': password,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'tenantId': tenantId,
      };
}
