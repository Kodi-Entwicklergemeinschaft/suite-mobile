import 'package:network/network.dart';
import 'enums/moderation_status.dart';
import 'enums/visibility.dart';
import 'enums/source_type.dart';
import 'listing_tag_model.dart';
import 'listing_media_model.dart';

class ListingTimeInterval implements BaseModel {
  final String? id;
  final List<String>? weekdays;
  final String? start;
  final String? end;
  final String? tz;
  final String? freq;
  final int? interval;
  final String? repeatUntil;

  ListingTimeInterval({
    this.id,
    this.weekdays,
    this.start,
    this.end,
    this.tz,
    this.freq,
    this.interval,
    this.repeatUntil,
  });

  @override
  ListingTimeInterval fromJson(Map<String, dynamic> json) {
    return ListingTimeInterval(
      id: json['id'] as String?,
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      start: json['start'] as String?,
      end: json['end'] as String?,
      tz: json['tz'] as String?,
      freq: json['freq'] as String?,
      interval: json['interval'] as int?,
      repeatUntil: json['repeatUntil'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'weekdays': weekdays,
        'start': start,
        'end': end,
        'tz': tz,
        'freq': freq,
        'interval': interval,
        'repeatUntil': repeatUntil,
      };
}

class ListingCategoryModel {
  final String? slug;
  final bool? isPrimary;
  final String? title;

  const ListingCategoryModel({this.slug, this.isPrimary, this.title});

  factory ListingCategoryModel.fromJson(Map<String, dynamic> json) {
    return ListingCategoryModel(
      slug: json['slug'] as String?,
      isPrimary: json['isPrimary'] as bool?,
      title: json['title'] as String?,
    );
  }
}

class ListingModel implements BaseModel {
  final String? id;
  final String? serviceId;
  final String? slug;
  final String? title;
  final String? summary;
  final String? content;
  final String? languageCode;
  final ModerationStatus? moderationStatus;
  final ListingVisibility? visibility;
  final bool? isFeatured;
  final String? publishAt;
  final String? expireAt;
  final String? heroImageUrl;
  final String? sourceUrl;
  final Map<String, dynamic>? metadata;
  final int? viewCount;
  final SourceType? sourceType;
  final String? venueName;
  final String? address;
  final double? geoLat;
  final double? geoLng;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final String? eventStart;
  final String? eventEnd;
  final bool? isAllDay;
  final String? organizerName;
  final String? registrationUrl;
  final String? createdAt;
  final String? updatedAt;
  final List<ListingTagModel>? tags;
  final List<ListingMediaModel>? media;
  final bool isFavourite;
  final String? categoryTitleBackgroundColor;
  final List<ListingCategoryModel>? categories;
  final double? distance;
  final List<ListingTimeInterval>? timeIntervals;
  final String? categoryFallbackImage;

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
    this.publishAt,
    this.expireAt,
    this.heroImageUrl,
    this.sourceUrl,
    this.metadata,
    this.viewCount,
    this.sourceType,
    this.venueName,
    this.address,
    this.geoLat,
    this.geoLng,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.eventStart,
    this.eventEnd,
    this.isAllDay,
    this.organizerName,
    this.registrationUrl,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.media,
    this.isFavourite = false,
    this.categoryTitleBackgroundColor,
    this.categories,
    this.distance,
    this.timeIntervals,
    this.categoryFallbackImage,
  });

  ListingModel copyWith({bool? isFavourite, double? distance}) {
    return ListingModel(
      id: id,
      serviceId: serviceId,
      slug: slug,
      title: title,
      summary: summary,
      content: content,
      languageCode: languageCode,
      moderationStatus: moderationStatus,
      visibility: visibility,
      isFeatured: isFeatured,
      publishAt: publishAt,
      expireAt: expireAt,
      heroImageUrl: heroImageUrl,
      sourceUrl: sourceUrl,
      metadata: metadata,
      viewCount: viewCount,
      sourceType: sourceType,
      venueName: venueName,
      address: address,
      geoLat: geoLat,
      geoLng: geoLng,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      website: website,
      eventStart: eventStart,
      eventEnd: eventEnd,
      isAllDay: isAllDay,
      organizerName: organizerName,
      registrationUrl: registrationUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      media: media,
      isFavourite: isFavourite ?? this.isFavourite,
      categoryTitleBackgroundColor: categoryTitleBackgroundColor,
      categories: categories,
      distance: distance ?? this.distance,
      timeIntervals: timeIntervals,
      categoryFallbackImage: categoryFallbackImage,
    );
  }

  @override
  ListingModel fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>? ?? json;
    return ListingModel(
      id: d['id'] as String?,
      serviceId: d['serviceId'] as String?,
      slug: d['slug'] as String?,
      title: d['title'] as String?,
      summary: d['summary'] as String?,
      content: d['content'] as String?,
      languageCode: d['languageCode'] as String?,
      moderationStatus: ModerationStatus.fromApiValue(d['moderationStatus'] as String?),
      visibility: ListingVisibility.fromApiValue(d['visibility'] as String?),
      isFeatured: d['isFeatured'] as bool?,
      publishAt: d['publishAt'] as String?,
      expireAt: d['expireAt'] as String?,
      heroImageUrl: d['heroImageUrl'] as String?,
      sourceUrl: d['sourceUrl'] as String?,
      metadata: d['metadata'] as Map<String, dynamic>?,
      viewCount: d['viewCount'] as int?,
      sourceType: SourceType.fromApiValue(d['sourceType'] as String?),
      venueName: d['venueName'] as String?,
      address: d['address'] as String?,
      geoLat: (d['geoLat'] as num?)?.toDouble(),
      geoLng: (d['geoLng'] as num?)?.toDouble(),
      contactPhone: d['contactPhone'] as String?,
      contactEmail: d['contactEmail'] as String?,
      website: d['website'] as String?,
      eventStart: d['eventStart'] as String?,
      eventEnd: d['eventEnd'] as String?,
      isAllDay: d['isAllDay'] as bool?,
      organizerName: d['organizerName'] as String?,
      registrationUrl: d['registrationUrl'] as String?,
      createdAt: d['createdAt'] as String?,
      updatedAt: d['updatedAt'] as String?,
      tags: (d['tags'] as List<dynamic>?)
          ?.map((e) => ListingTagModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      media: (d['media'] as List<dynamic>?)
          ?.map((e) => ListingMediaModel().fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavourite: d['isFavourite'] as bool? ?? d['isFavorite'] as bool? ?? false,
      categoryTitleBackgroundColor: d['categoryTitleBackgroundColor'] as String?,
      categoryFallbackImage: d['categoryFallbackImage'] as String?,
      categories: (d['categories'] as List<dynamic>?)
          ?.map((e) => ListingCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeIntervals: (d['timeIntervals'] as List<dynamic>?)
          ?.map((e) => ListingTimeInterval().fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'slug': slug,
    'title': title,
    'summary': summary,
    'heroImageUrl': heroImageUrl,
    'eventStart': eventStart,
    'eventEnd': eventEnd,
    'address': address,
    'tags': tags?.map((e) => e.toJson()).toList(),
    'media': media?.map((e) => e.toJson()).toList(),
  };

  String? get firstImageUrl {
    if (heroImageUrl != null && heroImageUrl!.isNotEmpty) return heroImageUrl;
    final mediaUrl = media?.firstOrNull?.url;
    if (mediaUrl != null && mediaUrl.isNotEmpty) return mediaUrl;
    return categoryFallbackImage;
  }
}
