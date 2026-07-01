import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_response_model.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../repositories/listing_repository.dart';

class GetListingsUseCase {
  final ListingRepository repository;
  GetListingsUseCase({required this.repository});

  Future<Either<Exception, ListingResponseModel>> call(
    ListingFilterModel filter,
  ) {
    return repository.getListings(filter);
  }
}

final getListingsUseCaseProvider = Provider<GetListingsUseCase>((ref) {
  return GetListingsUseCase(repository: ref.read(listingRepositoryProvider));
});
