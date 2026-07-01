import 'package:network/network.dart';

class ImageUploadResponseModel implements BaseModel<ImageUploadResponseModel> {
  bool? success;
  ImageUploadData? data;
  String? message;
  String? timestamp;
  String? path;
  int? statusCode;

  ImageUploadResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  ImageUploadResponseModel fromJson(Map<String, dynamic> json) {
    return ImageUploadResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? ImageUploadData().fromJson(json['data'] as Map<String, dynamic>)
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

class ImageUploadData implements BaseModel<ImageUploadData> {
  String? url;
  String? key;
  String? visibility;
  String? entityType;
  String? mediaType;
  String? userId;

  ImageUploadData({
    this.url,
    this.key,
    this.visibility,
    this.entityType,
    this.mediaType,
    this.userId,
  });

  @override
  ImageUploadData fromJson(Map<String, dynamic> json) {
    return ImageUploadData(
      url: json['url'] as String?,
      key: json['key'] as String?,
      visibility: json['visibility'] as String?,
      entityType: json['entityType'] as String?,
      mediaType: json['mediaType'] as String?,
      userId: json['userId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'key': key,
      'visibility': visibility,
      'entityType': entityType,
      'mediaType': mediaType,
      'userId': userId,
    };
  }
}
