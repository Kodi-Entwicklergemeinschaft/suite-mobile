import 'package:network/network.dart';

class GetFavRequestModel extends BaseModel<GetFavRequestModel> {
  final int? page;
  final int? limit;
  final String? categorySlug;
  final String? eventStartFrom;
  final String? eventStartTo;

  GetFavRequestModel({
    this.page = 1,
    this.limit = 20,
    this.categorySlug,
    this.eventStartFrom,
    this.eventStartTo,
  });

  @override
  GetFavRequestModel fromJson(Map<String, dynamic> json) {
    return GetFavRequestModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      categorySlug: json['categorySlug'] as String?,
      eventStartFrom: json['eventStartFrom'] as String?,
      eventStartTo: json['eventStartTo'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (page != null) data['page'] = page;
    if (limit != null) data['limit'] = limit;
    if (categorySlug != null && categorySlug!.isNotEmpty) {
      data['categorySlug'] = categorySlug;
    }
    if (eventStartFrom != null && eventStartFrom!.isNotEmpty) {
      data['eventStartFrom'] = eventStartFrom;
    }
    if (eventStartTo != null && eventStartTo!.isNotEmpty) {
      data['eventStartTo'] = eventStartTo;
    }
    return data;
  }
}
