import 'package:network/network.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

/// Model representing FAQ response
/// Reuses ActionResponseModel from ServiceResponseModel pattern
class FAQModel extends BaseModel<FAQModel> {
  final String? title;
  final ActionResponseModel? action;
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;

  FAQModel({
    this.title,
    this.action,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  FAQModel fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};

    return FAQModel(
      title: dataMap['title'] as String?,
      action: dataMap['action'] != null
          ? ActionResponseModel().fromJson(dataMap['action'] as Map<String, dynamic>)
          : null,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode']?.toString(),
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'title': title,
        'action': action?.toJson(),
      },
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  FAQModel copyWith({
    String? title,
    ActionResponseModel? action,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
  }) {
    return FAQModel(
      title: title ?? this.title,
      action: action ?? this.action,
      success: success ?? this.success,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
    );
  }
}
