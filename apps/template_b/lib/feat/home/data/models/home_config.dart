import 'dart:developer';

import 'package:network/network.dart';
import 'package:template_b/core/constants/home_screen_constant.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';

// ============================================================================
// HOME CONFIG MODEL
// ============================================================================

class HomeConfigModel implements BaseModel {
  final HeaderConfig? header;
  final SearchBarConfig? searchBar;
  final HamburgerMenuConfig? hamburgerMenu;
  final QuickActionsConfig? quickActions;
  final LocalitiesConfig? localities;

  /// All banner_image slugs collected into a single list (supports N banners).
  final List<BannerConfig> banners;
  final ContentSliderConfig? contentSlider;
  final ContentFeedConfig? contentFeed;
  final PartnersConfig? partners;
  final List<HomeScreenConstant> order;

  HomeConfigModel({
    this.header,
    this.searchBar,
    this.hamburgerMenu,
    this.quickActions,
    this.localities,
    this.banners = const [],
    this.contentSlider,
    this.contentFeed,
    this.partners,
    required this.order,
  });

  @override
  HomeConfigModel fromJson(Map<String, dynamic> json) {
    final homeList = json['home'] as List? ?? [];
    final order = <HomeScreenConstant>[];

    HeaderConfig? header;
    SearchBarConfig? searchBar;
    HamburgerMenuConfig? hamburgerMenu;
    QuickActionsConfig? quickActions;
    LocalitiesConfig? localities;
    // Collect all banner_image entries into a list; bannerImage is added to
    // order only once (when the first banner is encountered).
    final banners = <BannerConfig>[];
    ContentSliderConfig? contentSlider;
    ContentFeedConfig? contentFeed;
    PartnersConfig? partners;

    for (final item in homeList) {
      final slug = HomeScreenConstant.fromValue(item['slug']);

      // Skip unknown components (add_listing, nav_services, or any future unknowns)
      if (slug == null) {
        final unknownSlug = item['slug'];
        log('[HomeConfig] Unknown component slug: $unknownSlug - skipping');
        continue;
      }

      // Add slug to order only once (bannerImage may appear multiple times)
      if (!order.contains(slug)) {
        order.add(slug);
      }

      switch (slug) {
        case HomeScreenConstant.headerImage:
          header = HeaderConfig.fromJson(item as Map<String, dynamic>);
        case HomeScreenConstant.searchBar:
          searchBar = SearchBarConfig.fromJson(item as Map<String, dynamic>);
        case HomeScreenConstant.hamburgerMenu:
          hamburgerMenu = HamburgerMenuConfig.fromJson(
            item as Map<String, dynamic>,
          );
        case HomeScreenConstant.quickActions:
          quickActions = QuickActionsConfig.fromJson(
            item as Map<String, dynamic>,
          );
        case HomeScreenConstant.localities:
          localities = LocalitiesConfig.fromJson(item as Map<String, dynamic>);
        case HomeScreenConstant.bannerImage:
          // Accumulate every banner_image entry
          banners.add(BannerConfig.fromJson(item as Map<String, dynamic>));
        case HomeScreenConstant.contentSlider:
          contentSlider = ContentSliderConfig.fromJson(
            item as Map<String, dynamic>,
          );
        case HomeScreenConstant.contentFeed:
          contentFeed = ContentFeedConfig.fromJson(
            item as Map<String, dynamic>,
          );
        case HomeScreenConstant.partners:
          partners = PartnersConfig.fromJson(item as Map<String, dynamic>);
      }
    }

    return HomeConfigModel(
      header: header,
      searchBar: searchBar,
      hamburgerMenu: hamburgerMenu,
      quickActions: quickActions,
      localities: localities,
      banners: banners,
      contentSlider: contentSlider,
      contentFeed: contentFeed,
      partners: partners,
      order: order,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'home': [
        ...order
            .where((slug) => slug != HomeScreenConstant.bannerImage)
            .map((slug) {
              return switch (slug) {
                HomeScreenConstant.headerImage => header?.toJson(),
                HomeScreenConstant.searchBar => searchBar?.toJson(),
                HomeScreenConstant.hamburgerMenu => hamburgerMenu?.toJson(),
                HomeScreenConstant.quickActions => quickActions?.toJson(),
                HomeScreenConstant.localities => localities?.toJson(),
                HomeScreenConstant.contentSlider => contentSlider?.toJson(),
                HomeScreenConstant.contentFeed => contentFeed?.toJson(),
                HomeScreenConstant.partners => partners?.toJson(),
                // bannerImage excluded above; handled separately below
                HomeScreenConstant.bannerImage => null,
              };
            })
            .where((e) => e != null),
        // Emit each banner individually so the round-trip matches the API shape
        ...banners.map((b) => b.toJson()),
      ],
    };
  }
}

// ============================================================================
// CONFIG MODELS
// ============================================================================

class HeaderConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final String? image;

  HeaderConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    this.image,
  });

  factory HeaderConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return HeaderConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      // Support both 'image' and 'image_url' for backward compatibility
      image: (data?['image'] ?? data?['image_url']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.headerImage.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
    },
  };
}

class SearchBarConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;

  SearchBarConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
  });

  factory SearchBarConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return SearchBarConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.searchBar.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
    },
  };
}

class HamburgerMenuConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;

  HamburgerMenuConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
  });

  factory HamburgerMenuConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return HamburgerMenuConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.hamburgerMenu.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
    },
  };
}

class QuickActionsConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final List<ServiceResponseModel> items;

  QuickActionsConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    required this.items,
  });

  factory QuickActionsConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final itemsList = data?['items'] as List?;
    return QuickActionsConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      items:
          itemsList
              ?.map(
                (e) =>
                    ServiceResponseModel().fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.quickActions.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    },
  };
}

/// Variant types for localities widget
enum LocalityVariant {
  slider('slider'),
  dropdown('dropdown');

  final String value;
  const LocalityVariant(this.value);

  static LocalityVariant fromValue(String? value) {
    if (value == 'dropdown') return LocalityVariant.dropdown;
    return LocalityVariant.slider; // default
  }
}

class LocalitiesConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final String? title;
  final LocalityVariant variant;
  final int maxLocalities;

  LocalitiesConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    this.title,
    this.variant = LocalityVariant.slider,
    this.maxLocalities = 3,
  });

  factory LocalitiesConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LocalitiesConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      variant: LocalityVariant.fromValue(json['variant']),
      title: data?['title'],
      // Read maxLocalities from root level, fallback to data['max_selection'] for compatibility
      maxLocalities:
          (json['maxLocalities'] ?? data?['max_selection'] ?? 3) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.localities.value,
    'visible': visible,
    'variant': variant.value,
    'maxLocalities': maxLocalities,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (title != null) 'title': title,
    },
  };
}

class BannerConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final String? image;
  final ActionResponseModel? action;

  BannerConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    this.image,
    this.action,
  });

  factory BannerConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return BannerConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      // Support both 'image' and 'image_url' for backward compatibility
      image: (data?['image'] ?? data?['image_url']) as String?,
      action: data?['action'] != null
          ? ActionResponseModel().fromJson(
              data!['action'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.bannerImage.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (action != null) 'action': action!.toJson(),
    },
  };
}

// ============================================================================
// TEMPLATE B ACTION ITEM — single entry inside content_slider / content_feed items list
// ============================================================================

class TemplateBActionItem {
  final String? id;
  final String? label;
  final String? image;
  final String? icon;
  final String? title;
  final String? subtitle;
  final String? description;
  final ActionResponseModel? action;

  const TemplateBActionItem({
    this.id,
    this.label,
    this.image,
    this.icon,
    this.title,
    this.subtitle,
    this.description,
    this.action,
  });

  factory TemplateBActionItem.fromJson(Map<String, dynamic> json) {
    return TemplateBActionItem(
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

  String get displayTitle => title ?? label ?? '';

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

class HypertextModel {
  final String? label;
  final ActionResponseModel? action;

  HypertextModel({this.label, this.action});

  factory HypertextModel.fromJson(Map<String, dynamic> json) {
    return HypertextModel(
      label: json['label'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(
              json['action'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    if (action != null) 'action': action!.toJson(),
  };
}

class ContentSliderConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final String? title;
  final String? source;
  final String? serviceId;
  final String? slug;
  final int? limit;
  final String? category;
  final String? apiUrl;
  final ActionResponseModel? action;
  final HypertextModel? hypertext;
  final String? image;
  final String? subtitle;
  final List<TemplateBActionItem>? items;

  ContentSliderConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    this.title,
    this.source,
    this.serviceId,
    this.slug,
    this.limit,
    this.category,
    this.apiUrl,
    this.action,
    this.hypertext,
    this.image,
    this.subtitle,
    this.items,
  });

  factory ContentSliderConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ContentSliderConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      title: data?['title'],
      source: data?['source'],
      serviceId: data?['serviceId'],
      slug: data?['slug'],
      limit: data?['limit'],
      category: data?['category'],
      apiUrl: data?['apiUrl'],
      action: data?['action'] != null
          ? ActionResponseModel().fromJson(
              data!['action'] as Map<String, dynamic>,
            )
          : null,
      hypertext: json['hypertext'] != null
          ? HypertextModel.fromJson(json['hypertext'] as Map<String, dynamic>)
          : null,
      image: data?['image'] as String?,
      subtitle: data?['subtitle'] as String?,
      items: (data?['items'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(TemplateBActionItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.contentSlider.value,
    'visible': visible,
    if (hypertext != null) 'hypertext': hypertext!.toJson(),
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (serviceId != null) 'serviceId': serviceId,
      if (slug != null) 'slug': slug,
      if (limit != null) 'limit': limit,
      if (category != null) 'category': category,
      if (apiUrl != null) 'apiUrl': apiUrl,
      if (action != null) 'action': action!.toJson(),
      if (image != null) 'image': image,
      if (subtitle != null) 'subtitle': subtitle,
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    },
  };
}

class ContentFeedConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final String? title;
  final String? source;
  final String? serviceId;
  final String? slug;
  final int? limit;
  final ActionResponseModel? action;
  final String? image;
  final String? subtitle;
  final List<TemplateBActionItem>? items;

  ContentFeedConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    this.title,
    this.source,
    this.serviceId,
    this.slug,
    this.limit,
    this.action,
    this.image,
    this.subtitle,
    this.items,
  });

  factory ContentFeedConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ContentFeedConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      title: data?['title'],
      source: data?['source'],
      serviceId: data?['serviceId'],
      slug: data?['slug'],
      limit: data?['limit'],
      action: data?['action'] != null
          ? ActionResponseModel().fromJson(
              data!['action'] as Map<String, dynamic>,
            )
          : null,
      image: data?['image'] as String?,
      subtitle: data?['subtitle'] as String?,
      items: (data?['items'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(TemplateBActionItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.contentFeed.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (serviceId != null) 'serviceId': serviceId,
      if (slug != null) 'slug': slug,
      if (limit != null) 'limit': limit,
      if (action != null) 'action': action!.toJson(),
      if (image != null) 'image': image,
      if (subtitle != null) 'subtitle': subtitle,
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    },
  };
}

class PartnerItem {
  final String? label;
  final String? description;
  final String? image;
  final ActionResponseModel? action;

  PartnerItem({this.label, this.description, this.image, this.action});

  factory PartnerItem.fromJson(Map<String, dynamic> json) {
    return PartnerItem(
      label: json['label'],
      description: json['description'],
      image: json['image'],
      action: json['action'] != null
          ? ActionResponseModel().fromJson(
              json['action'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    if (description != null) 'description': description,
    if (image != null) 'image': image,
    if (action != null) 'action': action!.toJson(),
  };
}

class PartnersConfig {
  final String? id;
  final bool visible;
  final String? label;
  final String? description;
  final List<PartnerItem> items;

  PartnersConfig({
    this.id,
    this.visible = false,
    this.label,
    this.description,
    required this.items,
  });

  factory PartnersConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final itemsList = data?['items'] as List?;
    return PartnersConfig(
      id: json['id'],
      visible: json['visible'] ?? true,
      label: data?['label'],
      description: data?['description'],
      items:
          itemsList
              ?.map((e) => PartnerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'slug': HomeScreenConstant.partners.value,
    'visible': visible,
    'data': {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    },
  };
}

// ============================================================================
// REUSABLE ITEM MODELS
// ============================================================================

typedef CategoryItem = ServiceResponseModel;

class LocalityItem implements BaseModel {
  final String id;
  final String? code;
  final String? name;
  final String? description;
  final double? centerLat;
  final double? centerLng;
  final int? sortOrder;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final bool isSelected;
  final String? image;

  // Backward compatibility alias
  String? get label => name;

  LocalityItem({
    this.id = '',
    this.code,
    this.name,
    this.description,
    this.centerLat,
    this.centerLng,
    this.sortOrder,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.isSelected = false,
    this.image,
  });

  @override
  LocalityItem fromJson(Map<String, dynamic> json) {
    return LocalityItem(
      id: json['id'] ?? '',
      code: json['code'],
      name: json['name'] ?? json['label'],
      description: json['description'],
      centerLat: (json['centerLat'] as num?)?.toDouble(),
      centerLng: (json['centerLng'] as num?)?.toDouble(),
      sortOrder: json['sortOrder'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isSelected: json['is_selected'] ?? json['isSelected'] ?? false,
      image: json['image']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (centerLat != null) 'centerLat': centerLat,
      if (centerLng != null) 'centerLng': centerLng,
      if (sortOrder != null) 'sortOrder': sortOrder,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'isSelected': isSelected,
      if (image != null) 'image': image,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalityItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// API RESPONSE MODELS
// ============================================================================

class LocalityPaginationMeta {
  final int page;
  final int limit;
  final int total;
  final bool hasNextPage;

  const LocalityPaginationMeta({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.hasNextPage = false,
  });

  factory LocalityPaginationMeta.fromJson(Map<String, dynamic> json) {
    return LocalityPaginationMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

class LocalityListResponse implements BaseModel {
  final List<LocalityItem> items;
  final List<String> userSelectedLocalityIds;
  final LocalityPaginationMeta meta;
  // API wrapper fields
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;

  LocalityListResponse({
    this.items = const [],
    this.userSelectedLocalityIds = const [],
    this.meta = const LocalityPaginationMeta(),
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  LocalityListResponse fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    final itemsList = dataMap['items'] as List? ?? [];
    final selectedIds = (dataMap['userSelectedLocalityIds'] as List?) ?? [];
    final metaMap = dataMap['meta'] as Map<String, dynamic>?;

    return LocalityListResponse(
      items: itemsList
          .map((e) => LocalityItem().fromJson(e as Map<String, dynamic>))
          .toList(),
      userSelectedLocalityIds: selectedIds.cast<String>(),
      meta: metaMap != null
          ? LocalityPaginationMeta.fromJson(metaMap)
          : const LocalityPaginationMeta(),
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode']?.toString(),
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'userSelectedLocalityIds': userSelectedLocalityIds,
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }
}
