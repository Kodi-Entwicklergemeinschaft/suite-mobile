import 'package:network/network.dart';
import 'package:template_a/core/model/action_response_model.dart';

class ServiceResponseModel implements BaseModel {
  String? id;
  String? slug;
  String? label;
  String? title;
  String? subtitle;
  String? description;
  String? serviceImage;
  String? icon;
  String? serviceType;
  String? serviceTemplateId;
  String? titleBackgroundColor;
  String? descriptionBackgroundColor;
  int? order;
  ActionResponseModel? action;

  ServiceResponseModel({
    this.id,
    this.slug,
    this.label,
    this.title,
    this.subtitle,
    this.description,
    this.serviceImage,
    this.icon,
    this.serviceType,
    this.serviceTemplateId,
    this.titleBackgroundColor,
    this.descriptionBackgroundColor,
    this.order,
    this.action,
  });

  @override
  ServiceResponseModel fromJson(Map<String, dynamic> json) {
    return ServiceResponseModel(
      id: json['id'],
      slug: json['slug'],
      label: json['label'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      serviceImage: json['image'],
      icon: json['icon'],
      serviceType: json['serviceType'],
      serviceTemplateId: json['serviceTemplateId'],
      titleBackgroundColor: json['titleBackgroundColor'],
      descriptionBackgroundColor: json['descriptionBackgroundColor'],
      order: json['order'],
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
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image': serviceImage,
      'icon': icon,
      'serviceType': serviceType,
      'serviceTemplateId': serviceTemplateId,
      'titleBackgroundColor': titleBackgroundColor,
      'descriptionBackgroundColor': descriptionBackgroundColor,
      'order': order,
      'action': action?.toJson(),
    };
  }
}
