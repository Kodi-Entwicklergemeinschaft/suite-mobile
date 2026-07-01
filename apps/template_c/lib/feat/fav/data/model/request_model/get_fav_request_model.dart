import 'package:network/network.dart';
import '../../../constant/sort_by.dart';
import '../../../constant/sort_order.dart';

class GetFavRequestModel extends BaseModel<GetFavRequestModel> {
  final String? search;
  final String? subcategorySlug; // serializes as categorySlug (parent category)
  final String? childSubcategorySlug; // serializes as subcategorySlug (child)
  final List<String>? subcategorySlugs;
  final String? tagId;
  final bool? isFeatured;
  final String? createdByUserId;
  final DateTime? eventStartFrom;
  final DateTime? eventStartTo;
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;
  final int? page;
  final int? limit;
  final SortBy? sortBy;
  final SortOrder? sortOrder;
  final bool? eventSort;
  final bool requireLatLong;
  final bool requireEventStart;

  GetFavRequestModel({
    this.search,
    this.subcategorySlug,
    this.childSubcategorySlug,
    this.subcategorySlugs,
    this.tagId,
    this.isFeatured,
    this.createdByUserId,
    this.eventStartFrom,
    this.eventStartTo,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
    this.eventSort,
    this.requireLatLong = false,
    this.requireEventStart = false,
  });

  @override
  GetFavRequestModel fromJson(Map<String, dynamic> json) {
    return GetFavRequestModel(
      search: json['search'],
      subcategorySlug: json['subcategorySlug'],
      childSubcategorySlug: json['childSubcategorySlug'],
      subcategorySlugs: json['subcategorySlugs'] != null
          ? List<String>.from(json['subcategorySlugs'])
          : null,
      tagId: json['tagId'],
      isFeatured: json['isFeatured'],
      createdByUserId: json['createdByUserId'],
      eventStartFrom: json['eventStartFrom'] != null
          ? DateTime.tryParse(json['eventStartFrom'] as String)?.toLocal()
          : null,
      eventStartTo: json['eventStartTo'] != null
          ? DateTime.tryParse(json['eventStartTo'] as String)?.toLocal()
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: json['radiusMeters'],
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      eventSort: json['eventSort'],
      requireLatLong: json['requireLatLong'] ?? false,
      requireEventStart: json['requireEventStart'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfValid(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      if (value is Iterable && value.isEmpty) return;
      data[key] = value;
    }

    addIfValid('search', search);
    addIfValid('categorySlug', subcategorySlug);
    addIfValid('subcategorySlug', childSubcategorySlug);
    addIfValid('categorySlugs', subcategorySlugs?.join(','));
    addIfValid('tagId', tagId);
    addIfValid('isFeatured', isFeatured);
    addIfValid('createdByUserId', createdByUserId);
    addIfValid('eventStartFrom', eventStartFrom?.toUtc().toIso8601String());
    addIfValid('eventStartTo', eventStartTo?.toUtc().toIso8601String());
    addIfValid('latitude', latitude);
    addIfValid('longitude', longitude);
    addIfValid('radiusMeters', radiusMeters);
    addIfValid('page', page);
    addIfValid('limit', limit);
    addIfValid('sortBy', sortBy?.toApiValue());
    addIfValid('sortOrder', sortOrder?.toApiValue());
    addIfValid('eventSort', eventSort);
    addIfValid('requireLatLong', requireLatLong);
    addIfValid('requireEventStart', requireEventStart);

    return data;
  }
}
