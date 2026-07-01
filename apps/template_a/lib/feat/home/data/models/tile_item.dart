import 'package:template_a/core/model/action_response_model.dart';

class TileItem {
  final String? id;
  final String? label;
  final String? subtitle;
  final String? description;
  final String? icon;
  final String? image;
  final String? titleBackgroundColor;
  final ActionResponseModel? action;

  const TileItem({
    this.id,
    this.label,
    this.subtitle,
    this.description,
    this.icon,
    this.image,
    this.titleBackgroundColor,
    this.action,
  });

  // Convenience getters — backward-compat with TileSliderCarousel
  String? get actionType => action?.type;
  String? get actionTarget => action?.target;
  String? get actionUrl => action?.config?.url;
  bool get requireLogin => action?.config?.requireLogin ?? false;
  bool get requireShortCode => action?.config?.requiredShortCode ?? false;

  factory TileItem.fromJson(Map<String, dynamic> json) {
    final actionJson = json['action'] as Map<String, dynamic>?;
    return TileItem(
      id: json['id'] as String?,
      label: json['label'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      titleBackgroundColor: json['titleBackgroundColor'] as String?,
      action: actionJson != null
          ? ActionResponseModel().fromJson(actionJson)
          : null,
    );
  }
}
