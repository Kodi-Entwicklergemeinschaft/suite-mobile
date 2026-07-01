import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/feat/auth/controllers/auth_controller.dart';
import '../../../core/widgets/user_type_card.dart';
import 'onboarding_state.dart';


final onboardingControllerProvider = NotifierProvider.autoDispose<OnboardingController,OnboardingState>(() => OnboardingController());


class OnboardingController extends Notifier<OnboardingState>{
  @override
  OnboardingState build() {
    return OnboardingState();
  }

  void onPageChanged(int? index){
    state = state.copyWith(selectedPage: index??state.selectedPage+1);
  }

  void setResetPasswordActive(bool value) {
    state = state.copyWith(isResetPasswordActive: value);
  }

  void exitResetPassword() {
    state = state.copyWith(isResetPasswordActive: false, selectedPage: 3);
  }


}

