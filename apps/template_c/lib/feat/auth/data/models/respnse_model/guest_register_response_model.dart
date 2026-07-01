import 'package:network/network.dart';

/// Response model for guest user registration
class GuestRegisterResponseModel extends BaseModel<GuestRegisterResponseModel> {
  final bool? success;
  final Map<String, dynamic>? data;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  GuestRegisterResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  GuestRegisterResponseModel fromJson(Map<String, dynamic> json) {
    return GuestRegisterResponseModel(
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

  GuestRegisterResponseModel copyWith({
    bool? success,
    Map<String, dynamic>? data,
    String? message,
    String? timestamp,
    String? path,
    int? statusCode,
  }) {
    return GuestRegisterResponseModel(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
