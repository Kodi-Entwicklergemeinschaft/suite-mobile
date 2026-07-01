import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/listing_filter_config_response_model.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../repositories/listing_repository.dart';

class GetListingFilterConfigParams {
  final String categorySlug;

  GetListingFilterConfigParams({required this.categorySlug});
}

class GetListingFilterConfigUseCase
    implements BaseUseCase<ListingFilterConfigResponseModel, GetListingFilterConfigParams> {
  final ListingRepository repository;

  GetListingFilterConfigUseCase({required this.repository});

  @override
  Future<Either<Exception, ListingFilterConfigResponseModel>> call(
    GetListingFilterConfigParams params,
  ) {
    return repository.getFilterConfig(params.categorySlug);
  }
}

final getListingFilterConfigUseCaseProvider = Provider((ref) {
  return GetListingFilterConfigUseCase(
    repository: ref.watch(listingRepositoryProvider),
  );
});
