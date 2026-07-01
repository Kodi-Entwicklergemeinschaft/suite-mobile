import 'package:template_c/core/model/action_response_model.dart';

class BottomNavItemModel {
  final String? id;
  final String? slug;
  final String? label;
  final String? nickname;
  final String? iconUrl;
  final bool? isEnabled;
  final ActionResponseModel? action;

  BottomNavItemModel({
    this.id,
    this.slug,
    this.label,
    this.nickname,
    this.iconUrl,
    this.isEnabled,
    this.action,
  });

  factory BottomNavItemModel.fromJson(Map<String, dynamic> json) {
    return BottomNavItemModel(
      id: json['id'],
      slug: json['slug'],
      label: json['label'],
      nickname: json['nickname'],
      iconUrl: json['iconUrl'],
      isEnabled: json['isEnabled'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(json['action'])
          : null,
    );
  }
}
