import '../../data/model/locality_delivery_model.dart';
import '../../data/model/locality_model.dart';

abstract class LocalityRepo {
  Future<List<LocalityModel>> fetchLocalities(String serviceSlug);
  Future<LocalityDeliveryModel> fetchLocalityDelivery(
    String serviceSlug,
    String localityId,
  );
}
