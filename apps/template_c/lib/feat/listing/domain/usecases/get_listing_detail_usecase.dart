import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/listing/data/repositories/listing_repository_impl.dart';
import '../repositories/listing_repository.dart';
import '../../data/models/listing_model.dart';

final getListingDetailUseCaseProvider = Provider(
  (ref) => GetListingDetailUseCase(repository: ref.read(listingRepositoryProvider)),
);

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
