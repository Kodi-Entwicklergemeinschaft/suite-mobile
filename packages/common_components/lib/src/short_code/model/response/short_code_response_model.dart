import 'package:network/network.dart';

class ShortCodeResponseModel implements BaseModel<ShortCodeResponseModel> {
  bool? success;
  ShortCodeData? data;
  String? message;
  String? timestamp;
  String? path;
  int? statusCode;

  ShortCodeResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  ShortCodeResponseModel fromJson(Map<String, dynamic> json) {
    return ShortCodeResponseModel(
      success: json['success'],
      // We call fromJson on the ShortCodeData instance
      data: json['data'] != null ? ShortCodeData().fromJson(json['data']) : null,
      message: json['message'],
      timestamp: json['timestamp'],
      path: json['path'],
      statusCode: json['statusCode'],
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

class ShortCodeData implements BaseModel<ShortCodeData> {
  String? ottToken;
  String? portalUrl;
  String? expiresAt;

  ShortCodeData({this.ottToken, this.portalUrl, this.expiresAt});

  @override
  ShortCodeData fromJson(Map<String, dynamic> json) {
    return ShortCodeData(
      ottToken: json['ottToken'],
      portalUrl: json['portalUrl'],
      expiresAt: json['expiresAt'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ottToken': ottToken,
      'portalUrl': portalUrl,
      'expiresAt': expiresAt,
    };
  }
}