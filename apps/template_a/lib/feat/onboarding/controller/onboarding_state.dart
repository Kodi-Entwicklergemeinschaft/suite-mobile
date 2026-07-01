import 'package:template_a/core/constant/common_enums.dart';

import '../../../core/widgets/user_type_card.dart';

class OnboardingState {
  final int selectedPage;
  final StateEnum state;
  final bool isResetPasswordActive;

  OnboardingState({this.selectedPage = 0, this.state = StateEnum.initial, this.isResetPasswordActive = false});

  OnboardingState copyWith({int? selectedPage, StateEnum? state, bool? isResetPasswordActive}) {
    return OnboardingState(
      selectedPage: selectedPage ?? this.selectedPage,
      state: state ?? this.state,
      isResetPasswordActive: isResetPasswordActive ?? this.isResetPasswordActive,
    );
  }
}
