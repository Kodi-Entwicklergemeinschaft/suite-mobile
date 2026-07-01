class AccountState {
  final bool isLoggingOut;

  const AccountState({this.isLoggingOut = false});

  AccountState copyWith({bool? isLoggingOut}) {
    return AccountState(isLoggingOut: isLoggingOut ?? this.isLoggingOut);
  }
}