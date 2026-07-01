import 'package:template_c/core/constant/state_constant.dart';

class OnboardingState {
  StateConstant stateConstant;

  OnboardingState(this.stateConstant);

  OnboardingState copyWith({StateConstant? stateConstant}) {
    return OnboardingState(stateConstant ?? this.stateConstant);
  }
}
