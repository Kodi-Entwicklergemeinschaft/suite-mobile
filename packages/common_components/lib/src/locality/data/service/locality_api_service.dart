import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../model/get_localities_response_model.dart';
import '../model/locality_delivery_response_model.dart';

final localityApiServiceProvider = Provider<LocalityApiService>(
  (ref) => LocalityApiService(apiHelper: ref.watch(apiHelperProvider)),
);

class LocalityApiService {
  final ApiHelper apiHelper;

  LocalityApiService({required this.apiHelper});

  Future<Either<Exception, GetLocalitiesResponseModel>> fetchLocalities(
    String serviceSlug,
  ) {
    return apiHelper.getRequest(
      path: '/api/app-config/services/$serviceSlug/localities',
      create: () => GetLocalitiesResponseModel(),
    );
  }

  Future<Either<Exception, LocalityDeliveryResponseModel>>
      fetchLocalityDelivery(String serviceSlug, String localityId) {
    return apiHelper.getRequest(
      path: '/api/app-config/services/$serviceSlug/children',
      params: {'localityId': localityId},
      create: () => LocalityDeliveryResponseModel(),
    );
  }
}
