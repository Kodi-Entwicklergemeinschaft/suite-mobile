import 'package:network/network.dart';
import 'package:template_c/core/model/action_response_model.dart';

class BottomNavigationResponseModel
    implements BaseModel<BottomNavigationResponseModel> {
  bool? success;
  List<NavigationData>? data;
  String? message;
  String? timestamp;
  String? path;
  int? statusCode;

  BottomNavigationResponseModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
    this.path,
    this.statusCode,
  });

  @override
  BottomNavigationResponseModel fromJson(Map<String, dynamic> json) {
    return BottomNavigationResponseModel(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((i) => NavigationData.fromJson(i))
                .toList()
          : null,
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
      'data': data?.map((v) => v.toJson()).toList(),
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'statusCode': statusCode,
    };
  }
}

class NavigationData {
  String? id;
  String? slug;
  String? label;
  String? nickname;
  String? iconUrl;
  String? deactiveIconUrl;
  bool? isEnabled;
  ActionResponseModel? action;

  NavigationData({
    this.id,
    this.slug,
    this.label,
    this.nickname,
    this.iconUrl,
    this.deactiveIconUrl,
    this.isEnabled,
    this.action,
  });

  factory NavigationData.fromJson(Map<String, dynamic> json) {
    return NavigationData(
      id: json['id'],
      slug: json['slug'],
      label: json['label'],
      nickname: json['nickname'],
      // Handles both 'iconUrl' and 'active_iconUrl' variations in your JSON
      iconUrl: json['iconUrl'] ?? json['active_iconUrl'],
      deactiveIconUrl: json['deactive_iconUrl'],
      isEnabled: json['isEnabled'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(json['action'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'label': label,
      'nickname': nickname,
      'iconUrl': iconUrl,
      'deactive_iconUrl': deactiveIconUrl,
      'isEnabled': isEnabled,
      'action': action?.toJson(),
    };
  }
}
