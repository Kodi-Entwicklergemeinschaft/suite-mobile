import 'package:network/network.dart';
import 'package:template_c/feat/organizer/data/models/organizer_model.dart';

class OrganizerResponseModel extends BaseModel<OrganizerResponseModel> {
  final List<OrganizerModel>? items;
  final OrganizerMetaModel? meta;
  final bool? success;
  final String? message;
  final int? subCount;

  OrganizerResponseModel({
    this.items,
    this.meta,
    this.success,
    this.message,
    this.subCount,
  });

  bool get hasNextPage => meta?.hasNextPage ?? false;
  int get total => meta?.total ?? 0;

  @override
  OrganizerResponseModel fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    return OrganizerResponseModel(
      items: (dataMap['items'] as List<dynamic>?)
          ?.map((e) => OrganizerModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: dataMap['meta'] != null
          ? OrganizerMetaModel()
              .fromJson(dataMap['meta'] as Map<String, dynamic>)
          : null,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      subCount: dataMap['subCount'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'items': items?.map((e) => e.toJson()).toList(),
        'meta': meta?.toJson(),
        'success': success,
        'message': message,
        'subCount': subCount,
      };
}

class OrganizerMetaModel extends BaseModel<OrganizerMetaModel> {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;

  OrganizerMetaModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  @override
  OrganizerMetaModel fromJson(Map<String, dynamic> json) {
    return OrganizerMetaModel(
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
