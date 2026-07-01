import 'locality_child_service.dart';

class LocalityDeliveryModel {
  final List<LocalityChildService> services;

  const LocalityDeliveryModel({required this.services});

  LocalityChildService? get firstService =>
      services.isNotEmpty ? services.first : null;
}
