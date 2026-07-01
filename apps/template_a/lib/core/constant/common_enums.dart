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

enum UserRole {
  user('user'),
  guest('guest'),
  admin('admin');

  final String value;

  const UserRole(this.value);

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }

  @override
  String toString() => value;
}
