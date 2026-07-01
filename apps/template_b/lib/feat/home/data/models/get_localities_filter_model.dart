import 'package:network/network.dart';

/// Filter model for /api/localities endpoint
class GetLocalitiesFilterModel implements BaseModel {
  final bool? isActive;
  final String? search;
  final int? page;
  final int? limit;

  GetLocalitiesFilterModel({
    this.isActive,
    this.search,
    this.page,
    this.limit,
  });

  /// Convert filter to query parameters for API request
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (isActive != null) params['isActive'] = isActive;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (page != null && page! > 1) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    return params;
  }

  @override
  GetLocalitiesFilterModel fromJson(Map<String, dynamic> json) {
    return GetLocalitiesFilterModel(
      isActive: json['isActive'] as bool?,
      search: json['search'] as String?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (isActive != null) 'isActive': isActive,
      if (search != null) 'search': search,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }
}
