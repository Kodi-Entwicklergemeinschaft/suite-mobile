import 'package:network/network.dart';

class NotificationPrefsResponseModel
    implements BaseModel<NotificationPrefsResponseModel> {
  bool? success;
  NotificationPrefsData? data;
  String? message;
  int? statusCode;

  NotificationPrefsResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  NotificationPrefsResponseModel fromJson(Map<String, dynamic> json) {
    return NotificationPrefsResponseModel(
      success: json['success'] as bool?,
      data: json['data'] is Map<String, dynamic>
          ? NotificationPrefsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      statusCode: json['statusCode'] is int
          ? json['statusCode'] as int
          : int.tryParse(json['statusCode']?.toString() ?? ''),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'statusCode': statusCode,
    };
  }
}

class NotificationPrefsData {
  final bool? notificationsEnabled;
  final bool? newsletterSubscribed;

  NotificationPrefsData({this.notificationsEnabled, this.newsletterSubscribed});

  factory NotificationPrefsData.fromJson(Map<String, dynamic> json) {
    return NotificationPrefsData(
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      newsletterSubscribed: json['newsletterSubscription'] != null ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
