import 'package:network/network.dart';

class QuickFilter {
  final String key;
  final String label;
  final int order;
  final String? imageUrl;
  final int? radiusMeters;

  QuickFilter({
    required this.key,
    required this.label,
    required this.order,
    this.imageUrl,
    this.radiusMeters,
  });

  factory QuickFilter.fromJson(Map<String, dynamic> json) {
    return QuickFilter(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      radiusMeters: json['radiusMeters'] as int?,
    );
  }
}

class CategoryChild {
  final String id;
  final String slug;
  final String title;
  final String? image;
  final bool isQuickFilter;
  final bool enabled;
  final String? quickFilterKey;
  final int? radiusMeters;
  final int order;

  CategoryChild({
    required this.id,
    required this.slug,
    required this.title,
    this.image,
    required this.isQuickFilter,
    this.enabled = true,
    this.quickFilterKey,
    this.radiusMeters,
    required this.order,
  });

  factory CategoryChild.fromJson(Map<String, dynamic> json) {
    return CategoryChild(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
      isQuickFilter: json['isQuickFilter'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      quickFilterKey: json['quickFilterKey'] as String?,
      radiusMeters: json['radiusMeters'] as int?,
      order: json['order'] as int? ?? 0,
    );
  }
}

class CategoryFilterModel implements BaseModel {
  final String id;
  final String slug;
  final String title;
  final String? icon;
  final String? image;
  final String? titleBackgroundColor;
  final String? descriptionBackgroundColor;
  final List<CategoryChild> children;

  CategoryFilterModel({
    required this.id,
    required this.slug,
    required this.title,
    this.icon,
    this.image,
    this.titleBackgroundColor,
    this.descriptionBackgroundColor,
    required this.children,
  });

  @override
  CategoryFilterModel fromJson(Map<String, dynamic> json) {
    final childList = json['children'] as List? ?? [];
    return CategoryFilterModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      titleBackgroundColor: json['titleBackgroundColor'] as String?,
      descriptionBackgroundColor: json['descriptionBackgroundColor'] as String?,
      children: childList
          .map((e) => CategoryChild.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'title': title,
  };

  List<CategoryChild> get quickFilters =>
      children.where((c) => c.enabled).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}

class CategoryFilterResponseModel implements BaseModel {
  final List<CategoryFilterModel> items;

  CategoryFilterResponseModel({this.items = const []});

  @override
  CategoryFilterResponseModel fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    return CategoryFilterResponseModel(
      items: data
          .map((e) => CategoryFilterModel(
                id: '',
                slug: '',
                title: '',
                children: [],
              ).fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {};
}
