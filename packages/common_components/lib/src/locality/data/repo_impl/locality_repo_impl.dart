import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/locality_delivery_model.dart';
import '../model/locality_model.dart';
import '../service/locality_api_service.dart';
import '../../domain/repo/locality_repo.dart';

final localityRepoImplProvider = Provider<LocalityRepoImpl>(
  (ref) => LocalityRepoImpl(service: ref.watch(localityApiServiceProvider)),
);

class LocalityRepoImpl implements LocalityRepo {
  final LocalityApiService service;

  LocalityRepoImpl({required this.service});

  @override
  Future<List<LocalityModel>> fetchLocalities(String serviceSlug) async {
    final result = await service.fetchLocalities(serviceSlug);
    return result.fold((e) => throw e, (r) => r.localities);
  }

  @override
  Future<LocalityDeliveryModel> fetchLocalityDelivery(
    String serviceSlug,
    String localityId,
  ) async {
    final result = await service.fetchLocalityDelivery(serviceSlug, localityId);
    return result.fold((e) => throw e, (r) => r.delivery!);
  }
}
