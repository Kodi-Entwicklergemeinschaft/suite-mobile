import 'package:network/network.dart';
import 'package:template_c/feat/listing/data/repositories/listing_repository_impl.dart';
import '../repositories/listing_repository.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getListingUseCaseProvider = Provider(
  (ref) => GetListingsUseCase(repository: ref.read(listingRepositoryProvider)),
);

class GetListingsUseCase
    implements BaseUseCase<ListingResponseModel, ListingFilterModel> {
  final ListingRepository repository;

  GetListingsUseCase({required this.repository});

  @override
  Future<Either<Exception, ListingResponseModel>> call(
    ListingFilterModel filter,
  ) {
    return repository.getListings(filter);
  }
}
