import 'package:network/network.dart';

class FavOfflineSyncResponseModel
    extends BaseModel<FavOfflineSyncResponseModel> {
  final bool? success;
  final FavOfflineSyncData? data;
  final String? message;
  final String? timestamp;
  final String? path;
  final int? statusCode;

  FavOfflineSyncResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  FavOfflineSyncResponseModel fromJson(Map<String, dynamic> json) {
    return FavOfflineSyncResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? FavOfflineSyncData().fromJson(json['data'] as Map<String, dynamic>)
          : null,
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
      'data': data?.toJson(),
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'statusCode': statusCode,
    };
  }
}

class FavOfflineSyncData extends BaseModel<FavOfflineSyncData> {
  final bool? success;

  FavOfflineSyncData({this.success});

  @override
  FavOfflineSyncData fromJson(Map<String, dynamic> json) {
    return FavOfflineSyncData(success: json['success'] as bool?);
  }

  @override
  Map<String, dynamic> toJson() => {'success': success};
}
