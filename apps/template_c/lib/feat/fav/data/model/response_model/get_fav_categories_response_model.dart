import 'package:network/network.dart';

class GetFavCategoriesResponseModel
    extends BaseModel<GetFavCategoriesResponseModel> {
  final bool success;
  final String? message;
  final List<FavCategoryItemModel>? data;

  GetFavCategoriesResponseModel({
    this.success = false,
    this.message,
    this.data,
  });

  @override
  GetFavCategoriesResponseModel fromJson(Map<String, dynamic> json) {
    // Response is a top-level array wrapped in the standard envelope,
    // OR a plain array — handle both.
    final rawData = json['data'] ?? json;
    final list = rawData is List ? rawData : null;
    return GetFavCategoriesResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: list
          ?.map((e) => FavCategoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

class FavCategoryItemModel {
  final String? id;
  final String? slug;
  final String? title;
  final String? image;
  final String? icon;
  final bool enabled;
  final List<FavCategoryItemModel> children;

  FavCategoryItemModel({
    this.id,
    this.slug,
    this.title,
    this.image,
    this.icon,
    this.enabled = true,
    this.children = const [],
  });

  factory FavCategoryItemModel.fromJson(Map<String, dynamic> json) {
    return FavCategoryItemModel(
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (e) => FavCategoryItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'title': title,
    'image': image,
    'icon': icon,
    'enabled': enabled,
    'children': children.map((e) => e.toJson()).toList(),
  };
}
