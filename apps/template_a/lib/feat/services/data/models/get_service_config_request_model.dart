import 'package:network/network.dart';

class GetServiceConfigRequestModel implements BaseModel {
  final int? page;
  final int? limit;
  final bool? enabled;
  final bool? includeChildren;
  final String? serviceType;
  final bool? includeNonFeature;
  final String? search;

  GetServiceConfigRequestModel({
    this.page,
    this.limit,
    this.enabled,
    this.includeChildren,
    this.serviceType,
    this.includeNonFeature,
    this.search,
  });

  @override
  GetServiceConfigRequestModel fromJson(Map<String, dynamic> json) {
    return GetServiceConfigRequestModel(
      page: json['page'],
      limit: json['limit'],
      enabled: json['enabled'],
      includeChildren: json['includeChildren'],
      serviceType: json['serviceType'],
      includeNonFeature: json['includeNonFeature'],
      search: json['search'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (enabled != null) 'enabled': enabled.toString(),
      if (includeChildren != null) 'includeChildren': includeChildren.toString(),
      if (serviceType != null) 'serviceType': serviceType,
      if (includeNonFeature != null) 'includeNonFeature': includeNonFeature.toString(),
      if (search != null) 'search': search,
    };
  }
}
