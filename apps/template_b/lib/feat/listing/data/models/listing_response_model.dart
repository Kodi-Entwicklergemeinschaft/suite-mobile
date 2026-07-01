import 'package:network/network.dart';
import 'listing_model.dart';

/// Model for paginated listings response from API
class ListingResponseModel extends BaseModel<ListingResponseModel> {
  final List<ListingModel>? items;
  final ListingMetaModel? meta;
  // Wrapper fields from API response
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;

  ListingResponseModel({
    this.items,
    this.meta,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  ListingResponseModel fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};

    return ListingResponseModel(
      items: (dataMap['items'] as List<dynamic>?)
          ?.map((e) => ListingModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: dataMap['meta'] != null
          ? ListingMetaModel().fromJson(dataMap['meta'] as Map<String, dynamic>)
          : ListingMetaModel(
              page: dataMap['page'] as int?,
              limit: dataMap['limit'] as int?,
              total: dataMap['total'] as int?,
              totalPages: dataMap['totalPages'] as int?,
              hasNextPage: dataMap['hasNextPage'] as bool?,
              hasPreviousPage: dataMap['hasPreviousPage'] as bool?,
            ),
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
      'items': items?.map((e) => e.toJson()).toList(),
      'meta': meta?.toJson(),
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  ListingResponseModel copyWith({
    List<ListingModel>? items,
    ListingMetaModel? meta,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
  }) {
    return ListingResponseModel(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      success: success ?? this.success,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
    );
  }

  // Convenience accessors forwarded from meta
  int? get total => meta?.total;
  int? get page => meta?.page;
  int? get limit => meta?.limit;
  int? get totalPages => meta?.totalPages;

  bool get isEmpty => items == null || items!.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get hasNextPage => meta?.hasNextPage ?? (page != null && totalPages != null && page! < totalPages!);
  bool get hasPreviousPage => meta?.hasPreviousPage ?? (page != null && page! > 1);
}

class ListingMetaModel extends BaseModel<ListingMetaModel> {
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
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}
