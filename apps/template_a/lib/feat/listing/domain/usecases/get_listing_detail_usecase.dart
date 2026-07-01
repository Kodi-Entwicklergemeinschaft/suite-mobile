import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../repositories/listing_repository.dart';

class GetListingDetailParams {
  final String listingId;
  final bool bySlug;
  final String? categorySlug;

  GetListingDetailParams({required this.listingId, this.bySlug = false, this.categorySlug});
}

class GetListingDetailUseCase implements BaseUseCase<ListingModel, GetListingDetailParams> {
  final ListingRepository repository;

  GetListingDetailUseCase({required this.repository});

  @override
  Future<Either<Exception, ListingModel>> call(GetListingDetailParams params) {
    if (params.bySlug) {
      return repository.getListingBySlug(params.listingId);
    }
    return repository.getListingById(params.listingId, categorySlug: params.categorySlug);
  }
}

final getListingDetailUseCaseProvider = Provider<GetListingDetailUseCase>((ref) {
  return GetListingDetailUseCase(repository: ref.watch(listingRepositoryProvider));
});
