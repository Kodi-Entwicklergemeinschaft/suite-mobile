import 'package:network/network.dart';

class RemoveFavResponseModel extends BaseModel<RemoveFavResponseModel> {
  final bool success;
  final String? message;

  /// Placeholder for endpoint response body.
  final Map<String, dynamic> data;

  RemoveFavResponseModel({
    this.success = false,
    this.message,
    Map<String, dynamic>? data,
  }) : data = data ?? const {};

  @override
  RemoveFavResponseModel fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return RemoveFavResponseModel(
      success: success,
      message: message,
      data: data,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      'data': data,
    };
  }
}

