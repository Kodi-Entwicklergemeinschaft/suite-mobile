import 'package:template_c/core/constant/common_enums.dart';

class SignupState {

  final bool showPassword;
  final bool showConfirmPassword;
  // final String? errorMessage;
  final StateEnum state;
  final String? message;

  SignupState(
    {
      this.showPassword = false, 
      this.showConfirmPassword = false, 
      // this.errorMessage, 
      this.state = StateEnum.initial, 
      this.message
    }
  );

  SignupState copywith(
    {
      bool? showPassword,
      bool? showConfirmPassword, 
      // String? errorMessage, 
      StateEnum? state,
      String? message,
    }
  ){
    return SignupState(
      showPassword: showPassword ?? this.showPassword, 
      showConfirmPassword : showConfirmPassword ?? this.showConfirmPassword, 
      // errorMessage: errorMessage, 
      state: state ?? this.state,
      message: message,
    );
  }

}
