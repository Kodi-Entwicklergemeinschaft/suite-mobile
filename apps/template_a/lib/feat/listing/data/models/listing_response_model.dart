import 'package:network/network.dart';
import 'listing_model.dart';

class ListingResponseModel implements BaseModel {
  final List<ListingModel>? items;
  final ListingMetaModel? meta;
  final bool? success;
  final String? message;

  ListingResponseModel({this.items, this.meta, this.success, this.message});

  @override
  ListingResponseModel fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>? ?? {};
    return ListingResponseModel(
      items: (d['items'] as List<dynamic>?)
          ?.map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: d['meta'] != null
          ? ListingMetaModel().fromJson(d['meta'] as Map<String, dynamic>)
          : ListingMetaModel(
              page: d['page'] as int?,
              limit: d['limit'] as int?,
              total: d['total'] as int?,
              totalPages: d['totalPages'] as int?,
              hasNextPage: d['hasNextPage'] as bool?,
              hasPreviousPage: d['hasPreviousPage'] as bool?,
            ),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'items': items?.map((e) => e.toJson()).toList(),
    'meta': meta?.toJson(),
  };

  ListingResponseModel copyWith({
    List<ListingModel>? items,
    ListingMetaModel? meta,
  }) {
    return ListingResponseModel(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      success: success,
      message: message,
    );
  }

  bool get isEmpty => items == null || items!.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get hasNextPage => meta?.hasNextPage ?? false;
  int? get total => meta?.total;
  int? get page => meta?.page;
  int? get totalPages => meta?.totalPages;
}

class ListingMetaModel implements BaseModel {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;

  ListingMetaModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  @override
  ListingMetaModel fromJson(Map<String, dynamic> json) {
    return ListingMetaModel(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      totalPages: json['totalPages'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
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
  };
}
