import 'package:common_components/common_components.dart';
import 'package:network/network.dart';

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
      'actionConfig': action?.toJson(), // Key matched to JSON
    };
  }
}

class ActionResponseModel implements BaseModel {
  String? type;
  String? target;
  ConfigResponseModel? config;
  // action.variant — e.g. "list" | "accordion", lives at action level not inside config
  String? variant;
  String? localityMode;
  String? tenantServiceId;
  // Both set programmatically from the parent ServiceResponseModel when a card is tapped
  String? serviceSlug;
  String? serviceImage;
  // Set when navigating from a locality confirmation so feature routes receive it
  String? localityId;

  ActionResponseModel({
    this.type,
    this.target,
    this.config,
    this.variant,
    this.localityMode,
    this.tenantServiceId,
    this.serviceSlug,
    this.serviceImage,
    this.localityId,
  });
  // extract action confrim from locationality on confirm.
  factory ActionResponseModel.fromLocalityChild(
    LocalityChildService child, {
    required String localityId,
  }) {
    return ActionResponseModel(
      type: child.actionType,
      target: child.actionTarget,
      variant: child.actionVariant,
      tenantServiceId: child.id,
      serviceImage: child.image,
      localityId: localityId,
      config: child.actionConfig.isNotEmpty
          ? ConfigResponseModel().fromJson(child.actionConfig)
          : null,
    );
  }

  @override
  ActionResponseModel fromJson(Map<String, dynamic> json) {
    return ActionResponseModel(
      type: json['type'],
      target: json['target'],
      config: json['config'] != null
          ? ConfigResponseModel().fromJson(json['config'])
          : null,
      variant: json['variant'],
      localityMode: json['localityMode'],
      tenantServiceId: json['tenantServiceId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'target': target,
      'config': config?.toJson(),
      'variant': variant,
      'localityMode': localityMode,
      'tenantServiceId': tenantServiceId,
    };
  }
}

class ConfigResponseModel implements BaseModel {
  String? category;
  FiltersResponseModel? filters;
  String? view;
  String? url;
  String? layout;
  bool? toolbar;
  bool? injectTenant;
  List<ServiceResponseModel>? children;
  bool? requiredShortCode;
  bool? requireLogin;
  bool? requireLocalityServices;
  String? localityMode;
  String? tenantServiceId;
  List<LinkhubLinkModel>? links;
  List<LinkhubGroupModel>? groups;

  ConfigResponseModel({
    this.category,
    this.filters,
    this.view,
    this.url,
    this.layout,
    this.toolbar,
    this.injectTenant,
    this.children,
    this.requiredShortCode,
    this.requireLogin,
    this.requireLocalityServices,
    this.localityMode,
    this.tenantServiceId,
    this.links,
    this.groups,
  });

  @override
  ConfigResponseModel fromJson(Map<String, dynamic> json) {
    return ConfigResponseModel(
      category: json['category'],
      filters: json['filters'] != null
          ? FiltersResponseModel().fromJson(json['filters'])
          : null,
      view: json['view'],
      url: json['url'],
      layout: json['layout'],
      toolbar: json['toolbar'],
      injectTenant: json['injectTenant'],
      children: json['children'] != null
          ? (json['children'] as List)
                .map((i) => ServiceResponseModel().fromJson(i))
                .toList()
          : null,
      requiredShortCode: json['requireShortCode'],
      requireLogin: json['requireLogin'],
      requireLocalityServices: json['requireLocalityServices'],
      localityMode: json['localityMode'],
      tenantServiceId: json['tenantServiceId'],
      links: json['links'] != null
          ? (json['links'] as List)
                .map(
                  (e) => LinkhubLinkModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      groups: json['groups'] != null
          ? (json['groups'] as List)
                .map(
                  (e) => LinkhubGroupModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'filters': filters?.toJson(),
      'view': view,
      'url': url,
      'layout': layout,
      'toolbar': toolbar,
      'injectTenant': injectTenant,
      'children': children?.map((v) => v.toJson()).toList(),
      'requiredShortCode': requiredShortCode,
      'requireLogin': requireLogin,
      'requireLocalityServices': requireLocalityServices,
      'localityMode': localityMode,
      'tenantServiceId': tenantServiceId,
      'links': links
          ?.map(
            (e) => {
              'title': e.title,
              'url': e.url,
              'action': e.action,
              'image': e.image,
            },
          )
          .toList(),
      'groups': groups
          ?.map(
            (e) => {
              'title': e.title,
              'image': e.image,
              'links': e.links
                  .map(
                    (l) => {
                      'title': l.title,
                      'url': l.url,
                      'action': l.action,
                      'image': l.image,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }
}

class FiltersResponseModel implements BaseModel {
  List<String>? enabled;
  String? defaultFilter;
  int? nearbyRadiusMeters;

  FiltersResponseModel({
    this.enabled,
    this.defaultFilter,
    this.nearbyRadiusMeters,
  });

  @override
  FiltersResponseModel fromJson(Map<String, dynamic> json) {
    return FiltersResponseModel(
      enabled: json['enabled'] != null
          ? List<String>.from(json['enabled'])
          : null,
      defaultFilter: json['default'], // Map 'default' key from JSON
      nearbyRadiusMeters: json['nearbyRadiusMeters'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'default': defaultFilter,
      'nearbyRadiusMeters': nearbyRadiusMeters,
    };
  }
}
