import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';
import 'enums/sort_order.dart';
import 'enums/sort_by.dart';

class ListingFilterModel {
  final String? search;
  final String? categorySlug;
  final List<String>? categorySlugs;
  final String? subcategorySlug;
  final ModerationStatus? moderationStatus;
  final ListingVisibility? visibility;
  final SourceType? sourceType;
  final String? tagId;
  final bool? isFeatured;
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
  final List<String>? groupFilterIds;

  ListingFilterModel({
    this.search,
    this.categorySlug,
    this.categorySlugs,
    this.subcategorySlug,
    this.moderationStatus,
    this.visibility,
    this.sourceType,
    this.tagId,
    this.isFeatured,
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
    this.groupFilterIds,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (categorySlug != null && categorySlug!.isNotEmpty) params['categorySlug'] = categorySlug;
    if (categorySlugs != null && categorySlugs!.isNotEmpty) params['categorySlugs'] = categorySlugs;
    if (subcategorySlug != null && subcategorySlug!.isNotEmpty) params['subcategorySlug'] = subcategorySlug;
    if (moderationStatus != null) params['moderationStatus'] = moderationStatus!.toApiValue();
    if (visibility != null) params['visibility'] = visibility!.toApiValue();
    if (sourceType != null) params['sourceType'] = sourceType!.toApiValue();
    if (tagId != null && tagId!.isNotEmpty) params['tagId'] = tagId;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (eventStartFrom != null && eventStartFrom!.isNotEmpty) params['eventStartFrom'] = _toUtcIso(eventStartFrom!);
    if (eventStartTo != null && eventStartTo!.isNotEmpty) params['eventStartTo'] = _toUtcIso(eventStartTo!);
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;
    if (radiusMeters != null) params['radiusMeters'] = radiusMeters;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (sortBy != null) params['sortBy'] = sortBy!.toApiValue();
    if (sortOrder != null) params['sortOrder'] = sortOrder!.toApiValue();
    if (eventSort != null) params['eventSort'] = eventSort;
    if (groupFilterIds != null && groupFilterIds!.isNotEmpty) params['groupFilterIds'] = groupFilterIds;
    return params;
  }

  static String _toUtcIso(String value) {
    final dt = DateTime.tryParse(value);
    if (dt == null) return value;
    final utc = dt.toUtc();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${utc.year}-${pad(utc.month)}-${pad(utc.day)}'
        'T${pad(utc.hour)}:${pad(utc.minute)}:${pad(utc.second)}Z';
  }

  ListingFilterModel copyWith({
    String? search,
    String? categorySlug,
    List<String>? categorySlugs,
    String? subcategorySlug,
    ModerationStatus? moderationStatus,
    ListingVisibility? visibility,
    SourceType? sourceType,
    String? tagId,
    bool? isFeatured,
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
    List<String>? groupFilterIds,
  }) {
    return ListingFilterModel(
      search: search ?? this.search,
      categorySlug: categorySlug ?? this.categorySlug,
      categorySlugs: categorySlugs ?? this.categorySlugs,
      subcategorySlug: subcategorySlug ?? this.subcategorySlug,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      sourceType: sourceType ?? this.sourceType,
      tagId: tagId ?? this.tagId,
      isFeatured: isFeatured ?? this.isFeatured,
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
      groupFilterIds: groupFilterIds ?? this.groupFilterIds,
    );
  }
}
