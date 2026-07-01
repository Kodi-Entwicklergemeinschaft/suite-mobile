import 'package:network/network.dart';
import 'listing_tag_model.dart';
import 'listing_media_model.dart';
import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';

/// Model for individual listing (full detail view)
class ListingModel extends BaseModel<ListingModel> {
  final String? id;
  final String? serviceId;
  final String? slug;
  final String? title;
  final String? summary;
  final String? content;
  final String? languageCode;
  final ModerationStatus? moderationStatus;
  final Visibility? visibility;
  final bool? isFeatured;
  final String? featuredUntil;
  final String? publishAt;
  final String? expireAt;
  final String? heroImageUrl;
  final String? categoryFallbackImage;
  final String? sourceUrl;
  final Map<String, dynamic>? metadata;
  final int? viewCount;
  final int? likeCount;
  final int? shareCount;
  final SourceType? sourceType;
  final String? venueName;
  final String? address;
  final double? geoLat;
  final double? geoLng;
  final String? timezone;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final String? eventStart;
  final String? eventEnd;
  final bool? isAllDay;
  final String? organizerName;
  final String? registrationUrl;
  final bool? isArchived;
  final String? createdAt;
  final String? updatedAt;
  final List<ListingTagModel>? tags;
  final List<ListingMediaModel>? media;
  // Wrapper fields from API response
  final bool? success;
  final String? message;
  final String? statusCode;
  final String? timestamp;
  final String? path;

  ListingModel({
    this.id,
    this.serviceId,
    this.slug,
    this.title,
    this.summary,
    this.content,
    this.languageCode,
    this.moderationStatus,
    this.visibility,
    this.isFeatured,
    this.featuredUntil,
    this.publishAt,
    this.expireAt,
    this.heroImageUrl,
    this.categoryFallbackImage,
    this.sourceUrl,
    this.metadata,
    this.viewCount,
    this.likeCount,
    this.shareCount,
    this.sourceType,
    this.venueName,
    this.address,
    this.geoLat,
    this.geoLng,
    this.timezone,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.eventStart,
    this.eventEnd,
    this.isAllDay,
    this.organizerName,
    this.registrationUrl,
    this.isArchived,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.media,
    this.success,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  @override
  ListingModel fromJson(Map<String, dynamic> json) {
    // Extract from 'data' field if it exists (API wrapper structure)
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;

    return ListingModel(
      id: dataMap['id'] as String?,
      serviceId: dataMap['serviceId'] as String?,
      slug: dataMap['slug'] as String?,
      title: dataMap['title'] as String?,
      summary: dataMap['summary'] as String?,
      content: dataMap['content'] as String?,
      languageCode: dataMap['languageCode'] as String?,
      moderationStatus: ModerationStatus.fromApiValue(dataMap['moderationStatus'] as String?),
      visibility: Visibility.fromApiValue(dataMap['visibility'] as String?),
      isFeatured: dataMap['isFeatured'] as bool?,
      featuredUntil: dataMap['featuredUntil'] as String?,
      publishAt: dataMap['publishAt'] as String?,
      expireAt: dataMap['expireAt'] as String?,
      heroImageUrl: dataMap['heroImageUrl'] as String?,
      categoryFallbackImage: dataMap['categoryFallbackImage'] as String?,
      sourceUrl: dataMap['sourceUrl'] as String?,
      metadata: dataMap['metadata'] as Map<String, dynamic>?,
      viewCount: dataMap['viewCount'] as int?,
      likeCount: dataMap['likeCount'] as int?,
      shareCount: dataMap['shareCount'] as int?,
      sourceType: SourceType.fromApiValue(dataMap['sourceType'] as String?),
      venueName: dataMap['venueName'] as String?,
      address: dataMap['address'] as String?,
      geoLat: (dataMap['geoLat'] as num?)?.toDouble(),
      geoLng: (dataMap['geoLng'] as num?)?.toDouble(),
      timezone: dataMap['timezone'] as String?,
      contactPhone: dataMap['contactPhone'] as String?,
      contactEmail: dataMap['contactEmail'] as String?,
      website: dataMap['website'] as String?,
      eventStart: dataMap['eventStart'] as String?,
      eventEnd: dataMap['eventEnd'] as String?,
      isAllDay: dataMap['isAllDay'] as bool?,
      organizerName: dataMap['organizerName'] as String?,
      registrationUrl: dataMap['registrationUrl'] as String?,
      isArchived: dataMap['isArchived'] as bool?,
      createdAt: dataMap['createdAt'] as String?,
      updatedAt: dataMap['updatedAt'] as String?,
      tags: (dataMap['tags'] as List<dynamic>?)
          ?.map((e) => ListingTagModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      media: (dataMap['media'] as List<dynamic>?)
          ?.map((e) => ListingMediaModel().fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'serviceId': serviceId,
      'slug': slug,
      'title': title,
      'summary': summary,
      'content': content,
      'languageCode': languageCode,
      'moderationStatus': moderationStatus?.toApiValue(),
      'visibility': visibility?.toApiValue(),
      'isFeatured': isFeatured,
      'featuredUntil': featuredUntil,
      'publishAt': publishAt,
      'expireAt': expireAt,
      'heroImageUrl': heroImageUrl,
      'categoryFallbackImage': categoryFallbackImage,
      'sourceUrl': sourceUrl,
      'metadata': metadata,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'sourceType': sourceType?.toApiValue(),
      'venueName': venueName,
      'address': address,
      'geoLat': geoLat,
      'geoLng': geoLng,
      'timezone': timezone,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'website': website,
      'eventStart': eventStart,
      'eventEnd': eventEnd,
      'isAllDay': isAllDay,
      'organizerName': organizerName,
      'registrationUrl': registrationUrl,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tags': tags?.map((e) => e.toJson()).toList(),
      'media': media?.map((e) => e.toJson()).toList(),
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  ListingModel copyWith({
    String? id,
    String? serviceId,
    String? slug,
    String? title,
    String? summary,
    String? content,
    String? languageCode,
    ModerationStatus? moderationStatus,
    Visibility? visibility,
    bool? isFeatured,
    String? featuredUntil,
    String? publishAt,
    String? expireAt,
    String? heroImageUrl,
    String? categoryFallbackImage,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
    int? viewCount,
    int? likeCount,
    int? shareCount,
    SourceType? sourceType,
    String? venueName,
    String? address,
    double? geoLat,
    double? geoLng,
    String? timezone,
    String? contactPhone,
    String? contactEmail,
    String? website,
    String? eventStart,
    String? eventEnd,
    bool? isAllDay,
    String? organizerName,
    String? registrationUrl,
    bool? isArchived,
    String? createdAt,
    String? updatedAt,
    List<ListingTagModel>? tags,
    List<ListingMediaModel>? media,
    bool? success,
    String? message,
    String? statusCode,
    String? timestamp,
    String? path,
  }) {
    return ListingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      languageCode: languageCode ?? this.languageCode,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      publishAt: publishAt ?? this.publishAt,
      expireAt: expireAt ?? this.expireAt,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      categoryFallbackImage: categoryFallbackImage ?? this.categoryFallbackImage,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      metadata: metadata ?? this.metadata,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      sourceType: sourceType ?? this.sourceType,
      venueName: venueName ?? this.venueName,
      address: address ?? this.address,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      timezone: timezone ?? this.timezone,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      eventStart: eventStart ?? this.eventStart,
      eventEnd: eventEnd ?? this.eventEnd,
      isAllDay: isAllDay ?? this.isAllDay,
      organizerName: organizerName ?? this.organizerName,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      media: media ?? this.media,
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
