/// State representing delete account process
class DeleteAccountState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  DeleteAccountState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) => DeleteAccountState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isSuccess: isSuccess ?? this.isSuccess,
  );
}