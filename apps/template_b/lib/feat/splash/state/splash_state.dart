/// State representing splash screen loading status
class SplashState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const SplashState({
    this.isLoading = true,
    this.isSuccess = false,
    this.error,
  });

  bool get hasError => error != null;

  SplashState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}
