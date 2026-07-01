import 'dart:developer';

import 'package:network/network.dart';
import 'package:template_a/feat/category/data/models/category_filter_model.dart';
import 'package:template_a/feat/home/constants/home_screen_constant.dart';
import 'home_config_action_model.dart';
import 'tile_item.dart';


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

      components.add(
        ContentSliderConfig.fromJson(item as Map<String, dynamic>),
      );
    }

    return HomeConfigModel(components: components);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'home': components.map((c) => c.toJson()).toList()};
  }
}

class ComponentFilters {
  final bool requireLatLong;
  final bool requireEventStart;

  const ComponentFilters({
    this.requireLatLong = false,
    this.requireEventStart = false,
  });

  factory ComponentFilters.fromJson(Map<String, dynamic> json) {
    return ComponentFilters(
      requireLatLong: json['requireLatLong'] as bool? ?? false,
      requireEventStart: json['requireEventStart'] as bool? ?? false,
    );
  }
}


class ContentSliderConfig {
  final String? id;
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
  final HomeActionModel? action;
  final String? target;
  final ComponentFilters? filters;
  final String? image;
  final String? icon;
  final List<TileItem>? items;
  final bool? loginRequired;
  final String? titleBackgroundColor;
  final List<QuickFilter>? quickFilters;

  ContentSliderConfig({
    this.id,
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
    this.items,
    this.loginRequired,
    this.titleBackgroundColor,
    this.quickFilters,
  });

  factory ContentSliderConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final filtersJson = data?['filters'] as Map<String, dynamic>?;
    final itemsJson = data?['items'] as List?;
    return ContentSliderConfig(
      id: json['id'],
      variant: HomeScreenConstant.fromValue(json['slug'])!,
      visible: json['visible'] as bool? ?? true,
      label: data?['label'],
      description: data?['description'],
      serviceId: data?['serviceId'],
      category: (data?['category'] ?? data?['subCategory']) as String?,
      subcategory: (data?['subcategory'] ?? data?['subCategory']) as String?,
      title: data?['title'],
      source: data?['source'],
      limit: data?['limit'],
      action: data?['action'] != null
          ? HomeActionModel().fromJson(data!['action'] as Map<String, dynamic>)
          : null,
      target: data?['target'],
      filters: filtersJson != null
          ? ComponentFilters.fromJson(filtersJson)
          : null,
      image: data?['image'],
      icon: data?['icon'],
      items: itemsJson
          ?.whereType<Map<String, dynamic>>()
          .map(TileItem.fromJson)
          .toList(),
      loginRequired: json['loginRequired'] as bool?,
      titleBackgroundColor: data?['titleBackgroundColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': variant.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (serviceId != null) 'serviceId': serviceId,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (limit != null) 'limit': limit,
      if (action != null) 'action': action!.toJson(),
      if (target != null) 'target': target,
    },
  };
}
