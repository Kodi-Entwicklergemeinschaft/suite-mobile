import 'dart:developer';

import 'package:network/network.dart';
import 'package:template_c/core/model/action_response_model.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';

// ============================================================================
// HOME CONFIG MODEL
// ============================================================================

class HomeConfigModel implements BaseModel {
  final List<ContentSliderConfig> components;

  HomeConfigModel({required this.components});

  @override
  HomeConfigModel fromJson(Map<String, dynamic> json) {
    final homeList = json['home'] as List? ?? [];
    final components = <ContentSliderConfig>[];

    const skippedSlugs = {'nav_services'};

    for (final item in homeList) {
      final rawSlug = item['slug'] as String?;

      if (rawSlug != null && skippedSlugs.contains(rawSlug)) continue;

      final slug = HomeScreenConstant.fromValue(rawSlug);

      if (slug == null) {
        log('[HomeConfig] Unknown component slug: $rawSlug - skipping');
        continue;
      }

      final visible = item['visible'] as bool? ?? true;
      if (!visible) continue;

      components.add(
        ContentSliderConfig.fromJson(item as Map<String, dynamic>),
      );
    }

    components.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

    return HomeConfigModel(components: components);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'home': components.map((c) => c.toJson()).toList()};
  }
}

// ============================================================================
// API PARAM — a single entry inside a filter preset's apiParams list
// ============================================================================

class ApiParam {
  final String name;
  final dynamic value;
  final String source;

  const ApiParam({required this.name, this.value, required this.source});

  factory ApiParam.fromJson(Map<String, dynamic> json) => ApiParam(
    name: json['name'] as String,
    value: json['value'],
    source: json['source'] as String? ?? 'static',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (value != null) 'value': value,
    'source': source,
  };
}

// ============================================================================
// COMPONENT FILTER — one entry in the filters array
// ============================================================================

class ComponentFilter {
  final String key;
  final List<ApiParam> apiParams;

  const ComponentFilter({required this.key, required this.apiParams});

  factory ComponentFilter.fromJson(Map<String, dynamic> json) =>
      ComponentFilter(
        key: json['key'] as String? ?? '',
        apiParams: (json['apiParams'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ApiParam.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'apiParams': apiParams.map((p) => p.toJson()).toList(),
  };
}

// ============================================================================
// HOME ACTION ITEM — single entry inside a component's items list.
// Same data shape as the parent ContentSliderConfig data fields.
// ============================================================================

class HomeActionItem {
  final String? id;
  final String? label;
  final String? image;
  final String? icon;
  final String? title;
  final String? subtitle;
  final String? description;
  final ActionResponseModel? action;

  const HomeActionItem({
    this.id,
    this.label,
    this.image,
    this.icon,
    this.title,
    this.subtitle,
    this.description,
    this.action,
  });

  factory HomeActionItem.fromJson(Map<String, dynamic> json) {
    return HomeActionItem(
      id: json['id'] as String?,
      label: json['label'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      action: json['action'] != null
          ? ActionResponseModel().fromJson(
              json['action'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (label != null) 'label': label,
    if (image != null) 'image': image,
    if (icon != null) 'icon': icon,
    if (title != null) 'title': title,
    if (subtitle != null) 'subtitle': subtitle,
    if (description != null) 'description': description,
    if (action != null) 'action': action!.toJson(),
  };
}

// ============================================================================
// CONTENT SLIDER CONFIG
// ============================================================================

class ContentSliderConfig {
  final String? id;
  final String? instanceId;
  final int? position;
  final HomeScreenConstant variant;
  final bool visible;
  final String? label;
  final String? description;
  final String? serviceId;
  final String? category;
  final String? subcategory;
  final String? title;
  final String? source;
  final int? limit;
  final ActionResponseModel? action;
  final String? target;
  final List<ComponentFilter>? filters;
  final String? image;
  final String? icon;
  final String? titleBackgroundColor;
  final String? subtitle;
  final List<HomeActionItem>? items;

  ContentSliderConfig({
    this.id,
    this.instanceId,
    this.position,
    required this.variant,
    this.visible = true,
    this.label,
    this.description,
    this.serviceId,
    this.category,
    this.subcategory,
    this.title,
    this.source,
    this.limit,
    this.action,
    this.target,
    this.filters,
    this.image,
    this.icon,
    this.titleBackgroundColor,
    this.subtitle,
    this.items,
  });

  String get uniqueKey => instanceId!;

  factory ContentSliderConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ContentSliderConfig(
      id: json['id'],
      instanceId: json['instanceId'] as String?,
      position: json['position'] as int?,
      variant: HomeScreenConstant.fromValue(json['slug'])!,
      visible: json['visible'] as bool? ?? true,
      label: data?['label'],
      description: data?['description'],
      serviceId: data?['serviceId'],
      category: data?['category'],
      subcategory: data?['subCategory'] ?? data?['subcategory'],
      title: data?['title'],
      source: data?['source'],
      limit: data?['limit'],
      action: data?['action'] != null
          ? ActionResponseModel().fromJson(
              data!['action'] as Map<String, dynamic>,
            )
          : null,
      target: data?['target'],
      filters: (data?['filters'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(ComponentFilter.fromJson)
          .toList(),
      image: data?['image'],
      icon: data?['icon'],
      titleBackgroundColor: data?['titleBackgroundColor'],
      subtitle: data?['subtitle'],
      items: (data?['items'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(HomeActionItem.fromJson)
          .toList(),
    );
  }

  ListingFilterModel toListingFilter() {
    final extraParams = <String, dynamic>{};
    final deviceParams = <String>{};

    for (final f in filters ?? <ComponentFilter>[]) {
      for (final p in f.apiParams) {
        if (p.source == 'static') {
          extraParams[p.name] = p.value;
        } else if (p.source == 'device') {
          deviceParams.add(p.name);
        } else {
          log(
            '[HomeConfig] Unknown apiParam source: "${p.source}" for "${p.name}" — skipping',
          );
        }
      }
    }

    return ListingFilterModel(
      limit: limit ?? 10,
      categorySlug: subcategory == null ? category : null,
      subcategorySlug: subcategory,
      extraParams: extraParams,
      deviceParams: deviceParams,
      suppressDefaults: true,
      requireLatLong: false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (position != null) 'position': position,
    'slug': variant.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (serviceId != null) 'serviceId': serviceId,
      if (category != null) 'category': category,
      if (subcategory != null) 'subCategory': subcategory,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (limit != null) 'limit': limit,
      if (action != null) 'action': action!.toJson(),
      if (target != null) 'target': target,
      if (filters != null) 'filters': filters!.map((f) => f.toJson()).toList(),
      if (image != null) 'image': image,
      if (icon != null) 'icon': icon,
      if (titleBackgroundColor != null)
        'titleBackgroundColor': titleBackgroundColor,
      if (subtitle != null) 'subtitle': subtitle,
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    },
  };
}
