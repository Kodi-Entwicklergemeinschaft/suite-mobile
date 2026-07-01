import 'package:common_components/common_components.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/sub_service/model/response/service_response_model.dart';

class ActionResponseModel implements BaseModel {
  String? type;
  String? target;
  ConfigResponseModel? config;
  String? variant;
  String? serviceImage;

  ActionResponseModel({
    this.type,
    this.target,
    this.config,
    this.variant,
    this.serviceImage,
  });

  @override
  ActionResponseModel fromJson(Map<String, dynamic> json) {
    return ActionResponseModel(
      type: json['type'],
      target: json['target'],
      config: json['config'] != null
          ? ConfigResponseModel().fromJson(json['config'])
          : null,
      variant: json['variant'],
      serviceImage: json['serviceImage'] ?? json['image'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'target': target,
      'config': config?.toJson(),
      'variant': variant,
      'serviceImage': serviceImage,
    };
  }
}

class ConfigResponseModel implements BaseModel {
  String? category;
  String? subcategory;
  FiltersResponseModel? filters;
  String? view;
  String? url;
  String? layout;
  bool? toolbar;
  bool? injectTenant;
  bool? requiredShortCode;
  bool? requireLogin;
  List<ServiceResponseModel>? children;
  List<LinkhubLinkModel>? links;
  List<LinkhubGroupModel>? groups;

  ConfigResponseModel({
    this.category,
    this.subcategory,
    this.filters,
    this.view,
    this.url,
    this.layout,
    this.toolbar,
    this.injectTenant,
    this.requiredShortCode,
    this.requireLogin,
    this.children,
    this.links,
    this.groups,
  });

  @override
  ConfigResponseModel fromJson(Map<String, dynamic> json) {
    return ConfigResponseModel(
      category: json['category'],
      subcategory: json['subcategory'] ?? json['subCategory'],
      filters: json['filters'] != null
          ? FiltersResponseModel().fromJson(json['filters'])
          : null,
      view: json['view'],
      url: json['url'],
      layout: json['layout'],
      toolbar: json['toolbar'],
      injectTenant: json['injectTenant'],
      requiredShortCode: json['requireShortCode'],
      requireLogin: json['requireLogin'],
      children: json['children'] != null
          ? (json['children'] as List)
                .map((i) => ServiceResponseModel().fromJson(i))
                .toList()
          : null,
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
      'subcategory': subcategory,
      'filters': filters?.toJson(),
      'view': view,
      'url': url,
      'layout': layout,
      'toolbar': toolbar,
      'injectTenant': injectTenant,
      'requiredShortCode': requiredShortCode,
      'requireLogin': requireLogin,
      'children': children?.map((v) => v.toJson()).toList(),
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
