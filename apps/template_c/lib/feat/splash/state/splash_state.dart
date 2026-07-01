import 'package:template_c/core/constant/state_constant.dart';

/// State representing splash screen loading status
class SplashState {
  final bool isThemeLoaded;
  final String? error;
  final StateConstant stateConstant;

  const SplashState({
    this.isThemeLoaded = false,
    this.error,
    this.stateConstant = StateConstant.loading,
  });

  bool get hasError => error != null;

  SplashState copyWith({
    bool? isThemeLoaded,
    bool? isSuccess,
    String? error,
    StateConstant? stateConstant,
  }) {
    return SplashState(
      isThemeLoaded: isThemeLoaded ?? this.isThemeLoaded,
      error: error ?? this.error,
      stateConstant: stateConstant ?? this.stateConstant,
    );
  }
}
