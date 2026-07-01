import 'package:network/network.dart';

class AddFavResponseModel extends BaseModel<AddFavResponseModel> {
  final bool success;
  final String? message;

  /// Placeholder for endpoint response body.
  final Map<String, dynamic> data;

  AddFavResponseModel({
    this.success = false,
    this.message,
    Map<String, dynamic>? data,
  }) : data = data ?? const {};

  @override
  AddFavResponseModel fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return AddFavResponseModel(
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

