import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';
import 'enums/sort_order.dart';
import 'enums/sort_by.dart';

/// Model for listing API filter/query parameters
class ListingFilterModel {
  final String? search;
  final String? categorySlug;
  final String? subcategorySlug;
  final List<String>? subcategorySlugs;
  final ModerationStatus? moderationStatus;
  final Visibility? visibility;
  final SourceType? sourceType;
  final String? tagId;
  final bool? isFeatured;
  final bool? isHighlighted;
  final bool? isInterested;
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
  final bool requireEventEnd;
  final Map<String, dynamic> extraParams;
  final Set<String> deviceParams;

  // When true, constructor defaults for eventStartFrom / sortBy / sortOrder
  // are suppressed. Use for API-driven components (backend owns params via
  // extraParams/deviceParams) and bottom-nav tabs (no defaults needed).
  final bool suppressDefaults;

  ListingFilterModel({
    this.search,
    this.categorySlug,
    this.subcategorySlug,
    this.subcategorySlugs,
    this.moderationStatus,
    this.visibility,
    this.sourceType,
    this.tagId,
    this.isFeatured,
    this.isHighlighted,
    this.isInterested = true,
    this.createdByUserId,
    // DateTime? eventStartFrom,
    this.eventStartFrom,
    this.eventStartTo,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.page = 1,
    this.limit = 20,
    // SortBy? sortBy,
    // SortOrder? sortOrder,
    this.sortBy,
    this.sortOrder,
    this.eventSort,
    this.requireLatLong = true,
    this.requireEventStart = false,
    this.requireEventEnd = false,
    this.extraParams = const {},
    this.deviceParams = const {},
    this.suppressDefaults = false,
  });
  // eventStartFrom =
  //          eventStartFrom ?? (suppressDefaults ? null : DateTime.now()),
  //  sortBy = sortBy ?? (suppressDefaults ? null : SortBy.eventStart),
  //  sortOrder = sortOrder ?? (suppressDefaults ? null : SortOrder.asc);

  /// Convert filter to query parameters map
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (categorySlug != null && categorySlug!.isNotEmpty)
      params['categorySlug'] = categorySlug;
    if (subcategorySlug != null && subcategorySlug!.isNotEmpty)
      params['subcategorySlug'] = subcategorySlug;
    if (subcategorySlugs != null && subcategorySlugs!.isNotEmpty)
      params['subcategorySlugs'] = subcategorySlugs!.join(',');
    if (moderationStatus != null)
      params['moderationStatus'] = moderationStatus!.toApiValue();
    if (visibility != null) params['visibility'] = visibility!.toApiValue();
    if (sourceType != null) params['sourceType'] = sourceType!.toApiValue();
    if (tagId != null && tagId!.isNotEmpty) params['tagId'] = tagId;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (isHighlighted != null) params['isHighlighted'] = isHighlighted;

    final hasSubcategoryFilter =
        (categorySlug != null && categorySlug!.isNotEmpty) ||
        (subcategorySlug != null && subcategorySlug!.isNotEmpty) ||
        (subcategorySlugs != null && subcategorySlugs!.isNotEmpty);
    if (!hasSubcategoryFilter && isInterested != null)
      params['isInterested'] = isInterested;
    if (createdByUserId != null && createdByUserId!.isNotEmpty)
      params['createdByUserId'] = createdByUserId;
    if (eventStartFrom != null)
      params['eventStartFrom'] = eventStartFrom!.toUtc().toIso8601String();
    if (eventStartTo != null)
      params['eventStartTo'] = eventStartTo!.toUtc().toIso8601String();
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;
    if (radiusMeters != null) params['radiusMeters'] = radiusMeters;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (sortBy != null) params['sortBy'] = sortBy!.toApiValue();
    if (eventSort != null) params['eventSort'] = eventSort;
    if (sortOrder != null) params['sortOrder'] = sortOrder!.toApiValue();
    params.addAll(extraParams);

    return params;
  }

  Uri toDebugUri() => Uri(
    path: '/api/listings',
    queryParameters: toQueryParams().map((k, v) => MapEntry(k, '$v')),
  );

  ListingFilterModel copyWith({
    String? search,
    String? categorySlug,
    String? subcategorySlug,
    List<String>? subcategorySlugs,
    ModerationStatus? moderationStatus,
    Visibility? visibility,
    SourceType? sourceType,
    String? tagId,
    bool? isFeatured,
    bool? isHighlighted,
    bool? isInterested,
    String? createdByUserId,
    DateTime? eventStartFrom,
    DateTime? eventStartTo,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    int? page,
    int? limit,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? eventSort,
    bool? requireLatLong,
    bool? requireEventStart,
    bool? requireEventEnd,
    Map<String, dynamic>? extraParams,
    Set<String>? deviceParams,
    bool? suppressDefaults,
  }) {
    return ListingFilterModel(
      search: search ?? this.search,
      categorySlug: categorySlug ?? this.categorySlug,
      subcategorySlug: subcategorySlug ?? this.subcategorySlug,
      subcategorySlugs: subcategorySlugs ?? this.subcategorySlugs,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      sourceType: sourceType ?? this.sourceType,
      tagId: tagId ?? this.tagId,
      isFeatured: isFeatured ?? this.isFeatured,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isInterested: isInterested ?? this.isInterested,
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
      requireLatLong: requireLatLong ?? this.requireLatLong,
      requireEventStart: requireEventStart ?? this.requireEventStart,
      requireEventEnd: requireEventEnd ?? this.requireEventEnd,
      extraParams: extraParams ?? this.extraParams,
      deviceParams: deviceParams ?? this.deviceParams,
      suppressDefaults: suppressDefaults ?? this.suppressDefaults,
    );
  }

  @override
  String toString() => 'ListingFilterModel(${toQueryParams()})';
}
