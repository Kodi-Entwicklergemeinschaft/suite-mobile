import 'package:common_components/common_components.dart';
import 'package:hive/hive.dart';
import 'package:network/network.dart';
import 'listing_tag_model.dart';
import 'listing_media_model.dart';
import 'listing_metadata_model.dart';
import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';
import 'package:template_c/feat/organizer/data/models/organizer_model.dart';

part 'listing_model.g.dart';

/// Model for individual listing (full detail view)
@HiveType(typeId: 0)
class ListingModel extends BaseModel<ListingModel> {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? type;
  @HiveField(2)
  final String? serviceId;
  @HiveField(3)
  final String? slug;
  @HiveField(4)
  final String? categorySlug;
  @HiveField(5)
  final String? subcategorySlug;
  @HiveField(6)
  final String? categoryTitle;
  @HiveField(7)
  final String? subcategoryTitle;
  @HiveField(8)
  final String? title;
  @HiveField(9)
  final String? summary;
  @HiveField(10)
  final String? content;
  @HiveField(11)
  final String? languageCode;
  @HiveField(12)
  final String? status;
  @HiveField(13)
  final ModerationStatus? moderationStatus;
  @HiveField(14)
  final Visibility? visibility;
  @HiveField(15)
  final bool? isFeatured;
  @HiveField(16)
  final DateTime? featuredUntil;
  @HiveField(17)
  final DateTime? publishAt;
  @HiveField(18)
  final DateTime? expireAt;
  @HiveField(19)
  final String? heroImageUrl;
  @HiveField(52)
  final String? categoryFallbackImage;
  @HiveField(20)
  final String? sourceUrl;
  @HiveField(21)
  final ListingMetadata? metadataInfo;
  @HiveField(22)
  final int? viewCount;
  @HiveField(23)
  final int? likeCount;
  @HiveField(24)
  final int? shareCount;
  @HiveField(25)
  final SourceType? sourceType;
  @HiveField(26)
  final String? externalSource;
  @HiveField(27)
  final String? externalId;
  @HiveField(28)
  final DateTime? lastSyncedAt;
  @HiveField(29)
  final String? address;
  @HiveField(30)
  final String? venueName;
  @HiveField(31)
  final double? geoLat;
  @HiveField(32)
  final double? geoLng;
  @HiveField(33)
  final String? timezone;
  @HiveField(34)
  final String? website;
  @HiveField(35)
  final DateTime? eventStart;
  @HiveField(36)
  final DateTime? eventEnd;
  @HiveField(37)
  final bool? isAllDay;
  @HiveField(38)
  final bool? isArchived;
  @HiveField(39)
  final bool? isFavorite;
  @HiveField(40)
  final DateTime? createdAt;
  @HiveField(41)
  final DateTime? updatedAt;
  @HiveField(42)
  final List<ListingTagModel>? tags;
  @HiveField(43)
  final List<ListingMediaModel>? media;
  @HiveField(44)
  final List<dynamic>? localities;
  // Wrapper fields from API response
  @HiveField(45)
  final bool? success;
  @HiveField(46)
  final String? message;
  @HiveField(47)
  final String? statusCode;
  @HiveField(48)
  final String? timestamp;
  @HiveField(49)
  final String? path;
  @HiveField(50)
  final String? createdByUserId;
  @HiveField(51)
  final OrganizerModel? createdByUser;

  ListingModel({
    this.id,
    this.type,
    this.serviceId,
    this.slug,
    this.categorySlug,
    this.subcategorySlug,
    this.categoryTitle,
    this.subcategoryTitle,
    this.title,
    this.summary,
    this.content,
    this.languageCode,
    this.status,
    this.moderationStatus,
    this.visibility,
    this.isFeatured,
    this.featuredUntil,
    this.publishAt,
    this.expireAt,
    this.heroImageUrl,
    this.categoryFallbackImage,
    this.sourceUrl,
    this.metadataInfo,
    this.viewCount,
    this.likeCount,
    this.shareCount,
    this.sourceType,
    this.externalSource,
    this.externalId,
    this.lastSyncedAt,
    this.address,
    this.venueName,
    this.geoLat,
    this.geoLng,
    this.timezone,
    this.website,
    this.eventStart,
    this.eventEnd,
    this.isAllDay,
    this.isArchived,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.media,
    this.localities,
    this.isFavorite,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
    this.createdByUserId,
    this.createdByUser,
  });

  /// Convenience getters derived from metadataInfo — avoids scattered null
  /// checks across the UI layer.
  bool get isFreeEntry => metadataInfo?.isFree ?? false;
  String? get priceTag => metadataInfo?.priceLabel;
  String? get registrationUrl => metadataInfo?.externalParticipationUrl;
  String? get organizerName => metadataInfo?.publisher?.name;
  OrganizerModel? get organizer => createdByUser;

  /// Primary display image: heroImageUrl if present, else categoryFallbackImage.
  String? get resolvedImageUrl =>
      heroImageUrl?.isNotEmpty == true ? heroImageUrl : categoryFallbackImage;

  /// Non-null fallback used as errorWidget source when heroImageUrl fails.
  /// Only meaningful when both heroImageUrl and categoryFallbackImage exist.
  String? get imageFallback =>
      heroImageUrl?.isNotEmpty == true &&
          categoryFallbackImage?.isNotEmpty == true
      ? categoryFallbackImage
      : null;

  static DateTime? _parseLocal(String? iso) =>
      DateTimeHelper.parseUtcToLocal(iso);

  @override
  ListingModel fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    return ListingModel(
      id: dataMap['id'] as String?,
      type: dataMap['type'] as String?,
      serviceId: dataMap['serviceId'] as String?,
      slug: dataMap['slug'] as String?,
      categorySlug: dataMap['categorySlug'] as String?,
      subcategorySlug: dataMap['subcategorySlug'] as String?,
      categoryTitle: dataMap['categoryTitle'] as String?,
      subcategoryTitle: dataMap['subcategoryTitle'] as String?,
      title: dataMap['title'] as String?,
      summary: dataMap['summary'] as String?,
      content: dataMap['content'] as String?,
      languageCode: dataMap['languageCode'] as String?,
      status: dataMap['status'] as String?,
      moderationStatus: ModerationStatus.fromApiValue(
        dataMap['moderationStatus'] as String?,
      ),
      visibility: Visibility.fromApiValue(dataMap['visibility'] as String?),
      isFeatured: dataMap['isFeatured'] as bool?,
      featuredUntil: _parseLocal(dataMap['featuredUntil'] as String?),
      publishAt: _parseLocal(dataMap['publishAt'] as String?),
      expireAt: _parseLocal(dataMap['expireAt'] as String?),
      heroImageUrl: dataMap['heroImageUrl'] as String?,
      categoryFallbackImage: dataMap['categoryFallbackImage'] as String?,
      sourceUrl: dataMap['sourceUrl'] as String?,
      metadataInfo: dataMap['metadata'] != null
          ? ListingMetadata.fromJson(
              dataMap['metadata'] as Map<String, dynamic>,
            )
          : null,
      viewCount: dataMap['viewCount'] as int?,
      likeCount: dataMap['likeCount'] as int?,
      shareCount: dataMap['shareCount'] as int?,
      sourceType: SourceType.fromApiValue(dataMap['sourceType'] as String?),
      externalSource: dataMap['externalSource'] as String?,
      externalId: dataMap['externalId'] as String?,
      lastSyncedAt: _parseLocal(dataMap['lastSyncedAt'] as String?),
      address: dataMap['address'] as String?,
      venueName: dataMap['venueName'] as String?,
      geoLat: (dataMap['geoLat'] as num?)?.toDouble(),
      geoLng: (dataMap['geoLng'] as num?)?.toDouble(),
      timezone: dataMap['timezone'] as String?,
      website: dataMap['website'] as String?,
      eventStart: _parseLocal(dataMap['eventStart'] as String?),
      eventEnd: _parseLocal(dataMap['eventEnd'] as String?),
      isAllDay: dataMap['isAllDay'] as bool?,
      isArchived: dataMap['isArchived'] as bool?,
      createdAt: _parseLocal(dataMap['createdAt'] as String?),
      updatedAt: _parseLocal(dataMap['updatedAt'] as String?),
      tags: (dataMap['tags'] as List<dynamic>?)
          ?.map((e) => ListingTagModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      media: (dataMap['media'] as List<dynamic>?)
          ?.map((e) => ListingMediaModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      localities: dataMap['localities'] as List<dynamic>?,
      isFavorite: dataMap['isFavorite'] as bool?,
      createdByUserId: dataMap['createdByUserId'] as String?,
      createdByUser: dataMap['createdByUser'] != null
          ? OrganizerModel().fromJson(
              dataMap['createdByUser'] as Map<String, dynamic>,
            )
          : null,
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
      'id': id,
      'type': type,
      'serviceId': serviceId,
      'slug': slug,
      'categorySlug': categorySlug,
      'subcategorySlug': subcategorySlug,
      'categoryTitle': categoryTitle,
      'subcategoryTitle': subcategoryTitle,
      'title': title,
      'summary': summary,
      'content': content,
      'languageCode': languageCode,
      'status': status,
      'moderationStatus': moderationStatus?.toApiValue(),
      'visibility': visibility?.toApiValue(),
      'isFeatured': isFeatured,
      'featuredUntil': featuredUntil?.toUtc().toIso8601String(),
      'publishAt': publishAt?.toUtc().toIso8601String(),
      'expireAt': expireAt?.toUtc().toIso8601String(),
      'heroImageUrl': heroImageUrl,
      'categoryFallbackImage': categoryFallbackImage,
      'sourceUrl': sourceUrl,
      'metadata': metadataInfo?.toJson(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'sourceType': sourceType?.toApiValue(),
      'externalSource': externalSource,
      'externalId': externalId,
      'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
      'address': address,
      'venueName': venueName,
      'geoLat': geoLat,
      'geoLng': geoLng,
      'timezone': timezone,
      'website': website,
      'eventStart': eventStart?.toUtc().toIso8601String(),
      'eventEnd': eventEnd?.toUtc().toIso8601String(),
      'isAllDay': isAllDay,
      'isArchived': isArchived,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'tags': tags?.map((e) => e.toJson()).toList(),
      'media': media?.map((e) => e.toJson()).toList(),
      'localities': localities,
      'isFavorite': isFavorite,
      'createdByUserId': createdByUserId,
      'createdByUser': createdByUser?.toJson(),
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  ListingModel copyWith({
    String? id,
    String? type,
    String? serviceId,
    String? slug,
    String? categorySlug,
    String? subcategorySlug,
    String? categoryTitle,
    String? subcategoryTitle,
    String? title,
    String? summary,
    String? content,
    String? languageCode,
    String? status,
    ModerationStatus? moderationStatus,
    Visibility? visibility,
    bool? isFeatured,
    DateTime? featuredUntil,
    DateTime? publishAt,
    DateTime? expireAt,
    String? heroImageUrl,
    String? categoryFallbackImage,
    String? sourceUrl,
    ListingMetadata? metadataInfo,
    int? viewCount,
    int? likeCount,
    int? shareCount,
    SourceType? sourceType,
    String? externalSource,
    String? externalId,
    DateTime? lastSyncedAt,
    String? address,
    String? venueName,
    double? geoLat,
    double? geoLng,
    String? timezone,
    String? website,
    DateTime? eventStart,
    DateTime? eventEnd,
    bool? isAllDay,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListingTagModel>? tags,
    List<ListingMediaModel>? media,
    List<dynamic>? localities,
    bool? isFavorite,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
    String? createdByUserId,
    OrganizerModel? createdByUser,
  }) {
    return ListingModel(
      id: id ?? this.id,
      type: type ?? this.type,
      serviceId: serviceId ?? this.serviceId,
      slug: slug ?? this.slug,
      categorySlug: categorySlug ?? this.categorySlug,
      subcategorySlug: subcategorySlug ?? this.subcategorySlug,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      subcategoryTitle: subcategoryTitle ?? this.subcategoryTitle,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      languageCode: languageCode ?? this.languageCode,
      status: status ?? this.status,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      publishAt: publishAt ?? this.publishAt,
      expireAt: expireAt ?? this.expireAt,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      categoryFallbackImage:
          categoryFallbackImage ?? this.categoryFallbackImage,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      metadataInfo: metadataInfo ?? this.metadataInfo,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      sourceType: sourceType ?? this.sourceType,
      externalSource: externalSource ?? this.externalSource,
      externalId: externalId ?? this.externalId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      address: address ?? this.address,
      venueName: venueName ?? this.venueName,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      timezone: timezone ?? this.timezone,
      website: website ?? this.website,
      eventStart: eventStart ?? this.eventStart,
      eventEnd: eventEnd ?? this.eventEnd,
      isAllDay: isAllDay ?? this.isAllDay,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      media: media ?? this.media,
      localities: localities ?? this.localities,
      isFavorite: isFavorite ?? this.isFavorite,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUser: createdByUser ?? this.createdByUser,
      success: success ?? this.success,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      path: path ?? this.path,
    );
  }

  bool get isEmpty => id == null || id!.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
