import 'package:network/network.dart';
import 'locality_child_service.dart';
import 'locality_delivery_model.dart';

class LocalityDeliveryResponseModel
    extends BaseModel<LocalityDeliveryResponseModel> {
  final LocalityDeliveryModel? delivery;

  LocalityDeliveryResponseModel({this.delivery});

  @override
  LocalityDeliveryResponseModel fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawServices = data is Map ? data['services'] : null;
    final services = rawServices is List
        ? rawServices
            .map(
              (e) => LocalityChildService.fromJson(e as Map<String, dynamic>),
            )
            .toList()
        : <LocalityChildService>[];
    return LocalityDeliveryResponseModel(
      delivery: LocalityDeliveryModel(services: services),
    );
  }

  @override
  Map<String, dynamic> toJson() => {};
}
