import 'package:network/network.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'fav_category_model.dart';

class GetFavResponseModel extends BaseModel<GetFavResponseModel> {
  final bool success;
  final String? message;
  final List<ListingModel>? items;
  final GetFavMetaModel? meta;

  GetFavResponseModel({
    this.success = false,
    this.message,
    this.items,
    this.meta,
  });

  @override
  GetFavResponseModel fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final rawItems = (dataMap['items'] as List<dynamic>?) ?? [];

    // Build enrichment map: every slug (primary + subcategory) -> {imageUrl, bgColor}
    // meta.categories only has slug/title; the image/color live on each item.
    final enrichmentMap = <String, Map<String, String>>{};
    for (final e in rawItems) {
      final item = e as Map<String, dynamic>;
      final imageUrl = item['categoryFallbackImage'] as String? ?? '';
      final bgColor = item['categoryTitleBackgroundColor'] as String? ?? '';
      final entry = {'imageUrl': imageUrl, 'bgColor': bgColor};

      // Primary category slug
      final primarySlug = item['categorySlug'] as String?;
      if (primarySlug != null && !enrichmentMap.containsKey(primarySlug)) {
        enrichmentMap[primarySlug] = entry;
      }

      // All slugs from the categories array (includes subcategories)
      final cats = item['categories'] as List<dynamic>?;
      if (cats != null) {
        for (final cat in cats) {
          final slug = (cat as Map<String, dynamic>)['slug'] as String?;
          if (slug != null && !enrichmentMap.containsKey(slug)) {
            enrichmentMap[slug] = entry;
          }
        }
      }
    }

    GetFavMetaModel? meta;
    if (dataMap['meta'] != null) {
      final metaJson = dataMap['meta'] as Map<String, dynamic>;
      meta = GetFavMetaModel(
        page: metaJson['page'] as int?,
        limit: metaJson['limit'] as int?,
        total: metaJson['total'] as int?,
        totalPages: metaJson['totalPages'] as int?,
        hasNextPage: metaJson['hasNextPage'] as bool?,
        hasPreviousPage: metaJson['hasPreviousPage'] as bool?,
        categories: (metaJson['categories'] as List<dynamic>?)
            ?.map((e) {
              final c = e as Map<String, dynamic>;
              final slug = c['slug'] as String?;
              final enrich = enrichmentMap[slug] ?? {};
              return FavCategoryModel(
                slug: slug,
                title: c['title'] as String?,
                imageUrl: enrich['imageUrl'],
                headerBackgroundColor: enrich['bgColor'],
              );
            })
            .toList(),
      );
    }

    return GetFavResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      items: rawItems
          .map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: meta,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {
      'items': items?.map((e) => e.toJson()).toList(),
      'meta': meta?.toJson(),
    },
  };
}

class GetFavMetaModel extends BaseModel<GetFavMetaModel> {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  final List<FavCategoryModel>? categories;

  GetFavMetaModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
    this.categories,
  });

  @override
  GetFavMetaModel fromJson(Map<String, dynamic> json) {
    return GetFavMetaModel(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      totalPages: json['totalPages'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => FavCategoryModel().fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
    'hasNextPage': hasNextPage,
    'hasPreviousPage': hasPreviousPage,
    'categories': categories?.map((e) => e.toJson()).toList(),
  };
}
