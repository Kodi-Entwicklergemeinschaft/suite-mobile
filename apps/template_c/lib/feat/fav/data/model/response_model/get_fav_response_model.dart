import 'package:network/network.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/data/models/listing_response_model.dart';

class GetFavResponseModel extends BaseModel<GetFavResponseModel> {
  final bool success;
  final String? message;
  final List<ListingModel>? items;
  final GetFavMetaModel? meta;
  final int? statusCode;
  final String? timestamp;
  final String? path;

  GetFavResponseModel({
    this.success = false,
    this.message,
    this.items,
    this.meta,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  GetFavResponseModel fromJson(Map<String, dynamic> json) {
    // Navigate into the 'data' object for items and meta
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};

    return GetFavResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      // Map the items list from data.items
      items: (dataMap['items'] as List<dynamic>?)
          ?.map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      // Map the meta object from data.meta
      meta: dataMap['meta'] != null
          ? GetFavMetaModel().fromJson(dataMap['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
      'data': {
        'items': items?.map((e) => e.toJson()).toList(),
        'meta': meta?.toJson(),
      },
    };
  }

  // Helper getters for easier access
  bool get hasItems => items != null && items!.isNotEmpty;
  int get totalCount => meta?.total ?? 0;
}


class GetFavMetaModel extends BaseModel<GetFavMetaModel> {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  // Added categories field
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
      // Map the categories list
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => FavCategoryModel().fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
      'categories': categories?.map((e) => e.toJson()).toList(),
    };
  }
}

// Added CategoryModel to support the categories list in meta
class FavCategoryModel extends BaseModel<FavCategoryModel> {
  final String? slug;
  final String? title;

  FavCategoryModel({this.slug, this.title});

  @override
  FavCategoryModel fromJson(Map<String, dynamic> json) {
    return FavCategoryModel(
      slug: json['slug'] as String?,
      title: json['title'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'title': title,
    };
  }
}

