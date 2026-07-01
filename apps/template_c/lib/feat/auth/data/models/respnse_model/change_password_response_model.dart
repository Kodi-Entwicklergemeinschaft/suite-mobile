import 'package:network/network.dart';

/// Response model for change password request
class ChangePasswordResponseModel extends BaseModel<ChangePasswordResponseModel> {
  final bool? success;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  ChangePasswordResponseModel({
    this.success,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  ChangePasswordResponseModel fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'statusCode': statusCode,
    };
  }

  ChangePasswordResponseModel copyWith({
    bool? success,
    String? message,
    String? timestamp,
    String? path,
    int? statusCode,
  }) {
    return ChangePasswordResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
