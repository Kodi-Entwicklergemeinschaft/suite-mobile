import 'package:template_a/core/constant/common_enums.dart';

import '../../../core/widgets/user_type_card.dart';

class AuthState {
  final StateEnum state;
  final String? message;
  final UserTypeEnum? userType;
  final bool? isOnboarded;

  AuthState({
    this.state = StateEnum.initial,
    this.message,
    this.userType,
    this.isOnboarded,
  });

  AuthState copyWith({
    StateEnum? state,
    String? message,
    UserTypeEnum? userType,
    bool? isOnboarded,
  }) {
    return AuthState(
      state: state ?? this.state,
      message: message,
      userType: userType ?? this.userType,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
