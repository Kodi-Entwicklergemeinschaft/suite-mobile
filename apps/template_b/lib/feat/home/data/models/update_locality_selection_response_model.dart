import 'package:network/network.dart';

/// Response model for POST /api/localities/selection endpoint
class UpdateLocalitySelectionResponseModel
    extends BaseModel<UpdateLocalitySelectionResponseModel> {
  final bool? success;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  UpdateLocalitySelectionResponseModel({
    this.success,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  UpdateLocalitySelectionResponseModel fromJson(Map<String, dynamic> json) {
    return UpdateLocalitySelectionResponseModel(
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

  UpdateLocalitySelectionResponseModel copyWith({
    bool? success,
    String? message,
    String? timestamp,
    String? path,
    int? statusCode,
  }) {
    return UpdateLocalitySelectionResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
