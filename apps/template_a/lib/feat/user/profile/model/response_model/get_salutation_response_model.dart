import 'package:network/network.dart';

class GetSalutationResponseModel
    implements BaseModel<GetSalutationResponseModel> {
  bool? success;
  List<SalutationItem>? data;
  String? message;
  int? statusCode;

  GetSalutationResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  GetSalutationResponseModel fromJson(Map<String, dynamic> json) {
    return GetSalutationResponseModel(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => SalutationItem.fromJson(e)).toList()
          : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
      'statusCode': statusCode,
    };
  }
}

class SalutationItem {
  String? code;
  String? label;
  String? locale;
  int? sortOrder;

  SalutationItem({this.code, this.label, this.locale, this.sortOrder});

  factory SalutationItem.fromJson(Map<String, dynamic> json) {
    return SalutationItem(
      code: json['code'],
      label: json['label'],
      locale: json['locale'],
      sortOrder: json['sortOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'locale': locale,
      'sortOrder': sortOrder,
    };
  }
}