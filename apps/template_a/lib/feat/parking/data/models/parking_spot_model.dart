class ParkingSpotModel {
  final String id;
  final String parkingSiteId;
  final String name;
  final double lat;
  final double lng;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final String? lastObservedAt;
  final String? syncedAt;

  const ParkingSpotModel({
    required this.id,
    required this.parkingSiteId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
    this.lastObservedAt,
    this.syncedAt,
  });

  factory ParkingSpotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpotModel(
      id: json['id'] as String? ?? '',
      parkingSiteId: json['parkingSiteId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      totalSlots: json['totalSlots'] as int? ?? 0,
      availableSlots: json['availableSlots'] as int? ?? 0,
      occupiedSlots: json['occupiedSlots'] as int? ?? 0,
      lastObservedAt: json['lastObservedAt'] as String?,
      syncedAt: json['syncedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parkingSiteId': parkingSiteId,
      'name': name,
      'lat': lat,
      'lng': lng,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'occupiedSlots': occupiedSlots,
      if (lastObservedAt != null) 'lastObservedAt': lastObservedAt,
      if (syncedAt != null) 'syncedAt': syncedAt,
    };
  }
}
