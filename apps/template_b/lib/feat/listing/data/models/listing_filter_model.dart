import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';
import 'enums/sort_order.dart';
import 'enums/sort_by.dart';

/// Model for listing API filter/query parameters
class ListingFilterModel {
  final String? search;
  final String? categorySlug;
  final List<String>? categorySlugs;
  final ModerationStatus? moderationStatus;
  final Visibility? visibility;
  final SourceType? sourceType;
  final String? tagId;
  final bool? isFeatured;
  final String? createdByUserId;
  final String? eventStartFrom;
  final String? eventStartTo;
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;
  final int? page;
  final int? limit;
  final SortBy? sortBy;
  final SortOrder? sortOrder;
  final bool? eventSort;
  final bool? isSearch;

  ListingFilterModel({
    this.search,
    this.categorySlug,
    this.categorySlugs,
    this.moderationStatus,
    this.visibility,
    this.sourceType,
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
    this.isSearch,
  });

  /// Convert filter to query parameters map
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (categorySlug != null && categorySlug!.isNotEmpty) params['categorySlug'] = categorySlug;
    if (categorySlugs != null && categorySlugs!.isNotEmpty) params['categorySlugs'] = categorySlugs;
    if (moderationStatus != null) params['moderationStatus'] = moderationStatus!.toApiValue();
    if (visibility != null) params['visibility'] = visibility!.toApiValue();
    if (sourceType != null) params['sourceType'] = sourceType!.toApiValue();
    if (tagId != null && tagId!.isNotEmpty) params['tagId'] = tagId;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (createdByUserId != null && createdByUserId!.isNotEmpty) params['createdByUserId'] = createdByUserId;
    if (eventStartFrom != null && eventStartFrom!.isNotEmpty) params['eventStartFrom'] = eventStartFrom;
    if (eventStartTo != null && eventStartTo!.isNotEmpty) params['eventStartTo'] = eventStartTo;
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;
    if (radiusMeters != null) params['radiusMeters'] = radiusMeters;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (sortBy != null) params['sortBy'] = sortBy!.toApiValue();
    if (eventSort != null) params['eventSort'] = eventSort;
    if (sortOrder != null) params['sortOrder'] = sortOrder!.toApiValue();
    if (isSearch != null) params['searchEnable'] = isSearch;

    return params;
  }

  ListingFilterModel copyWith({
    String? search,
    String? categorySlug,
    List<String>? categorySlugs,
    ModerationStatus? moderationStatus,
    Visibility? visibility,
    SourceType? sourceType,
    String? tagId,
    bool? isFeatured,
    String? createdByUserId,
    String? eventStartFrom,
    String? eventStartTo,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    int? page,
    int? limit,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? eventSort,
    bool? isSearch,
  }) {
    return ListingFilterModel(
      search: search ?? this.search,
      categorySlug: categorySlug ?? this.categorySlug,
      categorySlugs: categorySlugs ?? this.categorySlugs,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      sourceType: sourceType ?? this.sourceType,
      tagId: tagId ?? this.tagId,
      isFeatured: isFeatured ?? this.isFeatured,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      eventStartFrom: eventStartFrom ?? this.eventStartFrom,
      eventStartTo: eventStartTo ?? this.eventStartTo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      eventSort: eventSort ?? this.eventSort,
      isSearch: isSearch ?? this.isSearch,
    );
  }
}
