/// Typed wrapper for the `metadata` object returned by the listings API.
class ListingMetadata {
  final ListingMetaPublisher? publisher;
  final ListingMetaAddress? address;
  final ListingMetaOptions? options;
  final String? joinOptions;
  final String? externalParticipationUrl;

  const ListingMetadata({
    this.publisher,
    this.address,
    this.options,
    this.joinOptions,
    this.externalParticipationUrl,
  });

  factory ListingMetadata.fromJson(Map<String, dynamic> json) {
    return ListingMetadata(
      publisher: json['publisher'] != null
          ? ListingMetaPublisher.fromJson(
              json['publisher'] as Map<String, dynamic>)
          : null,
      address: json['address'] != null
          ? ListingMetaAddress.fromJson(
              json['address'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? ListingMetaOptions.fromJson(
              json['options'] as Map<String, dynamic>)
          : null,
      joinOptions: json['joinOptions'] as String?,
      externalParticipationUrl:
          json['externalParticipationUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'publisher': publisher?.toJson(),
        'address': address?.toJson(),
        'options': options?.toJson(),
        'joinOptions': joinOptions,
        'externalParticipationUrl': externalParticipationUrl,
      };

  /// True when `joinOptions` is "FREE" and no paid offers exist.
  bool get isFree =>
      joinOptions?.toUpperCase() == 'FREE' &&
      (options?.offers?.isEmpty ?? true);

  /// Returns the first offer price label, or null if none.
  String? get priceLabel => options?.offers?.isNotEmpty == true
      ? options!.offers!.first
      : null;
}

// ─────────────────────────────────────────────────────────────────────────────

class ListingMetaPublisher {
  final String? id;
  final String? name;
  final String? type;
  final String? url;
  final String? avatar;
  final String? preferredUsername;

  const ListingMetaPublisher({
    this.id,
    this.name,
    this.type,
    this.url,
    this.avatar,
    this.preferredUsername,
  });

  factory ListingMetaPublisher.fromJson(Map<String, dynamic> json) {
    return ListingMetaPublisher(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      url: json['url'] as String?,
      avatar: json['avatar'] as String?,
      preferredUsername: json['preferredUsername'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'url': url,
        'avatar': avatar,
        'preferredUsername': preferredUsername,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class ListingMetaAddress {
  final String? street;
  final String? locality;
  final String? postalCode;
  final String? country;
  final String? description;
  final String? timezone;

  const ListingMetaAddress({
    this.street,
    this.locality,
    this.postalCode,
    this.country,
    this.description,
    this.timezone,
  });

  factory ListingMetaAddress.fromJson(Map<String, dynamic> json) {
    return ListingMetaAddress(
      street: json['street'] as String?,
      locality: json['locality'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'locality': locality,
        'postalCode': postalCode,
        'country': country,
        'description': description,
        'timezone': timezone,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class ListingMetaOptions {
  final List<String>? offers;
  final bool? isOnline;
  final int? maximumAttendeeCapacity;

  const ListingMetaOptions({
    this.offers,
    this.isOnline,
    this.maximumAttendeeCapacity,
  });

  factory ListingMetaOptions.fromJson(Map<String, dynamic> json) {
    return ListingMetaOptions(
      offers: (json['offers'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(),
      isOnline: json['isOnline'] as bool?,
      maximumAttendeeCapacity: json['maximumAttendeeCapacity'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'offers': offers,
        'isOnline': isOnline,
        'maximumAttendeeCapacity': maximumAttendeeCapacity,
      };
}
