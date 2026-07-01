typedef LocationResponseModel = List<LocationItemModel>;

LocationResponseModel locationResponseModelFromJsonList(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map<String, dynamic>>()
        .map(LocationItemModel.fromJson)
        .toList();
  }
  return <LocationItemModel>[];
}


class LocationItemModel {
  final int? placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final String? lat;
  final String? lon;
  final String? className;
  final String? type;
  final int? placeRank;
  final double? importance;
  final String? addresstype;
  final String? name;
  final String? displayName;
  final List<String>? boundingbox;

  LocationItemModel({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    this.lat,
    this.lon,
    this.className,
    this.type,
    this.placeRank,
    this.importance,
    this.addresstype,
    this.name,
    this.displayName,
    this.boundingbox,
  });

  factory LocationItemModel.fromJson(Map<String, dynamic> json) {
    return LocationItemModel(
      placeId: json['place_id'],
      licence: json['licence'],
      osmType: json['osm_type'],
      osmId: json['osm_id'],
      lat: json['lat'],
      lon: json['lon'],
      className: json['class'],
      type: json['type'],
      placeRank: json['place_rank'],
      importance: json['importance']?.toDouble(),
      addresstype: json['addresstype'],
      name: json['name'],
      displayName: json['display_name'],
      boundingbox: json['boundingbox'] != null
          ? List<String>.from(json['boundingbox'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'licence': licence,
      'osm_type': osmType,
      'osm_id': osmId,
      'lat': lat,
      'lon': lon,
      'class': className,
      'type': type,
      'place_rank': placeRank,
      'importance': importance,
      'addresstype': addresstype,
      'name': name,
      'display_name': displayName,
      'boundingbox': boundingbox,
    };
  }
}

