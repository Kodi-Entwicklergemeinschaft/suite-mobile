import 'package:network/network.dart';

class ActionResponseModel implements BaseModel {
  String? type;
  String? target;
  ConfigResponseModel? config;

  ActionResponseModel({this.type, this.target, this.config});

  @override
  ActionResponseModel fromJson(Map<String, dynamic> json) {
    return ActionResponseModel(
      type: json['type'],
      target: json['target'],
      config: json['config'] != null
          ? ConfigResponseModel().fromJson(json['config'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'target': target, 'config': config?.toJson()};
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
  bool? requiredShortCode;
  bool? requireLogin;
  bool? isGuestOnly;
  bool? isVisible;
  bool? isDialogue;
  bool? isFilter;
  bool? requireStartDate;
  bool? requireEndDate;
  String? dialogueContent;
  List<ServiceItemModel>? children;

  ConfigResponseModel({
    this.category,
    this.filters,
    this.view,
    this.url,
    this.layout,
    this.toolbar,
    this.injectTenant,
    this.requiredShortCode,
    this.requireLogin,
    this.isGuestOnly,
    this.isVisible,
    this.isDialogue,
    this.isFilter,
    this.requireStartDate,
    this.requireEndDate,
    this.dialogueContent,
    this.children,
  });

  @override
  ConfigResponseModel fromJson(Map<String, dynamic> json) {
    final rawVisible = json['isVisible'];
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
      requiredShortCode: json['requireShortCode'],
      requireLogin: json['requireLogin'],
      isGuestOnly: json['isGuestOnly'],
      isVisible: rawVisible == null
          ? null
          : rawVisible is bool
              ? rawVisible
              : rawVisible.toString().toLowerCase() != 'false',
      isDialogue: json['isDialogue'],
      isFilter: json['isFilter'],
      requireStartDate: json['requireStartDate'],
      requireEndDate: json['requireEndDate'],
      dialogueContent: json['dialogueContent'],
      children: json['children'] != null
          ? (json['children'] as List)
                .map((i) => ServiceItemModel().fromJson(i))
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
      'requiredShortCode': requiredShortCode,
      'requireLogin': requireLogin,
      'isGuestOnly': isGuestOnly,
      'isVisible': isVisible,
      'isDialogue': isDialogue,
      'isFilter': isFilter,
      'requireStartDate': requireStartDate,
      'requireEndDate': requireEndDate,
      'dialogueContent': dialogueContent,
      'children': children?.map((c) => c.toJson()).toList(),
    };
  }
}

class ServiceItemModel implements BaseModel {
  String? label;
  String? image;
  String? icon;
  String? titleBackgroundColor;
  ActionResponseModel? action;

  ServiceItemModel({this.label, this.image, this.icon, this.titleBackgroundColor, this.action});

  @override
  ServiceItemModel fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      label: json['label'],
      image: json['image'],
      icon: json['icon'],
      titleBackgroundColor: json['titleBackgroundColor'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(json['action'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'image': image,
      'icon': icon,
      'titleBackgroundColor': titleBackgroundColor,
      'action': action?.toJson(),
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
      defaultFilter: json['default'],
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
