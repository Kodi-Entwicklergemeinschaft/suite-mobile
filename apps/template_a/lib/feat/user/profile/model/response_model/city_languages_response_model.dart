import 'package:network/network.dart';

class CityLanguagesResponseModel implements BaseModel<CityLanguagesResponseModel> {
  bool? success;
  CityLanguagesData? data;
  String? message;
  int? statusCode;

  CityLanguagesResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  CityLanguagesResponseModel fromJson(Map<String, dynamic> json) {
    return CityLanguagesResponseModel(
      success: json['success'],
      data: json['data'] != null
          ? CityLanguagesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
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

class CityLanguagesData {
  final String? defaultLanguage;
  final List<String> enabledLanguages;

  CityLanguagesData({
    this.defaultLanguage,
    this.enabledLanguages = const [],
  });

  factory CityLanguagesData.fromJson(Map<String, dynamic> json) {
    return CityLanguagesData(
      defaultLanguage: json['defaultLanguage'] as String?,
      enabledLanguages: (json['enabledLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultLanguage': defaultLanguage,
      'enabledLanguages': enabledLanguages,
    };
  }
}