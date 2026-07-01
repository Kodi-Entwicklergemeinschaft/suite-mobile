import 'package:network/network.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

/// The Top-Level Response Model matching your JSON structure
class LegalResponseModel implements BaseModel<LegalResponseModel> {
  final bool? success;
  final List<LegalData>? data; 
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  LegalResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  LegalResponseModel fromJson(Map<String, dynamic> json) {
    return LegalResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      statusCode: json['statusCode'] as int?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => LegalData().fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
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
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents the individual legal items (Terms, Imprint, etc.)
class LegalData {
  final String? key;
  final String? title;
  final ActionResponseModel? action;

  LegalData({this.key, this.title, this.action});

  LegalData fromJson(Map<String, dynamic> json) {
    return LegalData(
      key: json['key'] as String?,
      title: json['title'] as String?,
      action: json['action'] != null
          ? ActionResponseModel().fromJson(json['action'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'action': action?.toJson(),
    };
  }
}
