import 'package:network/network.dart';
import 'package:template_a/core/model/action_response_model.dart';

class HomeActionFilters implements BaseModel {
  final String? defaultFilter;
  final List<String> enabled;
  final int? nearbyRadiusMeters;

  HomeActionFilters({
    this.defaultFilter,
    this.enabled = const [],
    this.nearbyRadiusMeters,
  });

  @override
  HomeActionFilters fromJson(Map<String, dynamic> json) {
    return HomeActionFilters(
      defaultFilter: json['default'],
      enabled: (json['enabled'] as List?)?.cast<String>() ?? [],
      nearbyRadiusMeters: json['nearbyRadiusMeters'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (defaultFilter != null) 'default': defaultFilter,
    'enabled': enabled,
    if (nearbyRadiusMeters != null) 'nearbyRadiusMeters': nearbyRadiusMeters,
  };
}

class HomeActionConfig implements BaseModel {
  final String? view;
  final String? category;
  final bool requireLogin;
  final String? url;
  final bool requireShortCode;
  final HomeActionFilters? filters;
  final List<ServiceItemModel>? children;

  HomeActionConfig({
    this.view,
    this.category,
    this.requireLogin = false,
    this.url,
    this.requireShortCode = false,
    this.filters,
    this.children,
  });

  @override
  HomeActionConfig fromJson(Map<String, dynamic> json) {
    return HomeActionConfig(
      view: json['view'],
      category: (json['category'] ?? json['subCategory']) as String?,
      requireLogin: json['requireLogin'] as bool? ?? false,
      url: json['url'],
      requireShortCode: json['requireShortCode'] as bool? ?? false,
      filters: json['filters'] != null
          ? HomeActionFilters().fromJson(json['filters'] as Map<String, dynamic>)
          : null,
      children: json['children'] != null
          ? (json['children'] as List)
                .map((i) => ServiceItemModel().fromJson(i))
                .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (view != null) 'view': view,
    if (category != null) 'category': category,
    'requireLogin': requireLogin,
    if (url != null) 'url': url,
    if (requireShortCode) 'requireShortCode': requireShortCode,
    if (filters != null) 'filters': filters!.toJson(),
    if (children != null)
      'children': children!.map((c) => c.toJson()).toList(),
  };
}

class HomeActionModel implements BaseModel {
  final String? type;
  final HomeActionConfig? config;
  final String? target;

  HomeActionModel({this.type, this.config, this.target});

  @override
  HomeActionModel fromJson(Map<String, dynamic> json) {
    return HomeActionModel(
      type: json['type'],
      config: json['config'] != null
          ? HomeActionConfig().fromJson(json['config'] as Map<String, dynamic>)
          : null,
      target: json['target'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (config != null) 'config': config!.toJson(),
    if (target != null) 'target': target,
  };
}
