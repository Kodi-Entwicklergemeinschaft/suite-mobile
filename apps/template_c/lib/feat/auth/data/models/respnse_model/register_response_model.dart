import 'package:network/network.dart';

/// Response model for user registration
class RegisterResponseModel extends BaseModel<RegisterResponseModel> {
  final bool? success;
  final Map<String, dynamic>? data;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  RegisterResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  RegisterResponseModel fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool?,
      data: json['data'] as Map<String, dynamic>?,
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
      'data': data,
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'statusCode': statusCode,
    };
  }

  RegisterResponseModel copyWith({
    bool? success,
    Map<String, dynamic>? data,
    String? message,
    String? timestamp,
    String? path,
    int? statusCode,
  }) {
    return RegisterResponseModel(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
