import 'package:network/network.dart';
import '../repositories/listing_repository.dart';
import '../../data/models/listing_model.dart';

/// Params for GetListingDetailUseCase
class GetListingDetailParams {
  final String listingId;
  final bool? bySlug;

  GetListingDetailParams({
    required this.listingId,
    this.bySlug = false,
  });
}

/// UseCase for fetching single listing detail by ID or slug
class GetListingDetailUseCase implements BaseUseCase<ListingModel, GetListingDetailParams> {
  final ListingRepository repository;

  GetListingDetailUseCase({required this.repository});

  @override
  Future<Either<Exception, ListingModel>> call(GetListingDetailParams params) {
    if (params.bySlug == true) {
      return repository.getListingBySlug(params.listingId);
    }
    return repository.getListingById(params.listingId);
  }
}
