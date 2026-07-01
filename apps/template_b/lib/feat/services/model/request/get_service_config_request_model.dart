import 'package:network/network.dart';

class GetServiceConfigRequestModel implements BaseModel {
  int? page;
  int? limit;
  bool? enabled;
  bool? includeChildren;
  String? search;
  bool resolveUserLocality;

  GetServiceConfigRequestModel({
    this.page,
    this.limit,
    this.enabled,
    this.includeChildren,
    this.search,
    this.resolveUserLocality = true,
  });

  @override
  fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    enabled = json['enabled'];
    includeChildren = json['includeChildren'];
    search = json['search'];
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (page != null) data['page'] = page.toString();
    if (limit != null) data['limit'] = limit.toString();
    if (enabled != null) data['enabled'] = enabled.toString();
    if (includeChildren != null)
      data['includeChildren'] = includeChildren.toString();
    if (search != null) data['search'] = search;
    data['resolveUserLocality'] = resolveUserLocality.toString();
    return data;
  }
}
