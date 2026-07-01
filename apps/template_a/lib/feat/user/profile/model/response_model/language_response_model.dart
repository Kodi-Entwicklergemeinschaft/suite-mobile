import 'package:network/network.dart';

class LanguageResponseModel implements BaseModel<LanguageResponseModel> {
  bool? success;
  LanguageData? data;
  String? message;
  int? statusCode;

  LanguageResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  LanguageResponseModel fromJson(Map<String, dynamic> json) {
    return LanguageResponseModel(
      success: json['success'],
      data: json['data'] != null ? LanguageData.fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'statusCode': statusCode,
    };
  }
}

class LanguageData {
  String? id;
  String? preferredLanguage;
  String? updatedAt;

  LanguageData({this.id, this.preferredLanguage, this.updatedAt});

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      id: json['id'],
      preferredLanguage: json['preferredLanguage'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferredLanguage': preferredLanguage,
      'updatedAt': updatedAt,
    };
  }
}