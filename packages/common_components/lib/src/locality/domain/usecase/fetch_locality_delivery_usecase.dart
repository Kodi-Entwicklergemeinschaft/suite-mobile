import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/locality_delivery_model.dart';
import '../../data/repo_impl/locality_repo_impl.dart';
import '../repo/locality_repo.dart';

final fetchLocalityDeliveryUsecaseProvider =
    Provider<FetchLocalityDeliveryUsecase>(
  (ref) => FetchLocalityDeliveryUsecase(
    repo: ref.watch(localityRepoImplProvider),
  ),
);

class FetchLocalityDeliveryUsecase {
  final LocalityRepo repo;

  FetchLocalityDeliveryUsecase({required this.repo});

  Future<LocalityDeliveryModel> call(String serviceSlug, String localityId) =>
      repo.fetchLocalityDelivery(serviceSlug, localityId);
}
