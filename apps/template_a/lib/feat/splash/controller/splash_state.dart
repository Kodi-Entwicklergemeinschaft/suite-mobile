import '../../../core/constant/state_constant.dart';

class SplashState {
  final bool isThemeLoaded;
  final bool isSplashReady;
  final String? error;
  final StateConstant stateConstant;

  const SplashState({
    this.isThemeLoaded = false,
    this.isSplashReady = false,
    this.error,
    this.stateConstant = StateConstant.loading,
  });

  bool get hasError => error != null;

  SplashState copyWith({
    bool? isThemeLoaded,
    bool? isSplashReady,
    bool? isSuccess,
    String? error,
    StateConstant? stateConstant,
  }) {
    return SplashState(
      isThemeLoaded: isThemeLoaded ?? this.isThemeLoaded,
      isSplashReady: isSplashReady ?? this.isSplashReady,
      error: error ?? this.error,
      stateConstant: stateConstant ?? this.stateConstant,
    );
  }
}
