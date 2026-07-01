import 'package:network/network.dart';

class ToggleOnboardedStatusRequestModel {
  final bool onboarded;

  ToggleOnboardedStatusRequestModel({required this.onboarded});

  Map<String, dynamic> toJson() {
    return {
      'onboarded': onboarded,
    };
  }
}

class ToggleOnboardedStatusResponseModel extends BaseModel<ToggleOnboardedStatusResponseModel> {
  final bool? success;
  final String? message;
  final bool? onboarded;

  ToggleOnboardedStatusResponseModel({
    this.success,
    this.message,
    this.onboarded,
  });
  
  @override
  ToggleOnboardedStatusResponseModel fromJson(Map<String, dynamic> json) {
    return ToggleOnboardedStatusResponseModel(
      success: json['success'],
      message: json['message'],
      onboarded: json['data']['onboarded']
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'onboarded': onboarded,
    };
  }
}