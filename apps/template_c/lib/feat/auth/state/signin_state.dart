import 'package:template_c/core/constant/common_enums.dart';

class SigninState {

  bool showPassword;
  String? message;
  final StateEnum state;
  final bool? isOnboarded;

  SigninState(
    {
      this.showPassword = false, 
      this.message, 
      this.state = StateEnum.initial,
      this.isOnboarded,
    }
  );

  SigninState copywith(
    {bool? showPassword,
    String? message, 
    StateEnum? state,
    bool? isOnboarded,
    }
  ){
    return SigninState(
      showPassword: showPassword ?? this.showPassword, 
      message: message, 
      state: state ?? this.state,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

}
