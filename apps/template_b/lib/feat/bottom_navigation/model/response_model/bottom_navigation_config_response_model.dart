import 'package:network/network.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

class BottomNavigationConfigResponseModel
    implements BaseModel<BottomNavigationConfigResponseModel> {
  List<BottomNavItemModel>? data;
  String? message;
  String? timestamp;
  int? statusCode;

  BottomNavigationConfigResponseModel({
    this.data,
    this.message,
    this.timestamp,
    this.statusCode,
  });

  @override
  BottomNavigationConfigResponseModel fromJson(Map<String, dynamic> json) {
    return BottomNavigationConfigResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BottomNavItemModel().fromJson(e))
          .toList(),
      message: json['message'],
      timestamp: json['timestamp'],
      statusCode: json['statusCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
      'timestamp': timestamp,
      'statusCode': statusCode,
    };
  }
}

class BottomNavItemModel implements BaseModel<BottomNavItemModel> {
  String? id;
  String? slug;
  String? label;
  String? nickname;
  String? iconUrl;
  bool? isEnabled;
  ActionResponseModel? action; // New field

  BottomNavItemModel({
    this.id,
    this.slug,
    this.label,
    this.nickname,
    this.iconUrl,
    this.isEnabled,
    this.action,
  });

  @override
  BottomNavItemModel fromJson(Map<String, dynamic> json) {
    return BottomNavItemModel(
      id: json['id'],
      slug: json['slug'],
      label: json['label'],
      nickname: json['nickname'],
      iconUrl: json['iconUrl'] ?? json['icon'],
      isEnabled: json['isEnabled'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(json['action'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'label': label,
      'nickname': nickname,
      'iconUrl': iconUrl,
      'isEnabled': isEnabled,
      'action': action?.toJson(),
    };
  }
}
