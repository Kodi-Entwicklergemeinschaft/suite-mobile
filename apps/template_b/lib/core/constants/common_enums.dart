enum StateEnum {
  loading,
  loadingDialog,
  success,
  error,
  errorSnackBar,
  initial;

  bool get isLoading {
    return this == StateEnum.loading || this == StateEnum.loadingDialog;
  }
}

/// User role enum for authentication
enum UserRole {
  user('user'),
  guest('guest'),
  admin('admin');

  final String value;

  const UserRole(this.value);

  /// Get UserRole from string value
  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user, // Default to 'user' role
    );
  }

  /// Convert UserRole to string value
  @override
  String toString() => value;
}
