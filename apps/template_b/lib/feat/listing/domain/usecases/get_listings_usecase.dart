import 'package:network/network.dart';
import '../repositories/listing_repository.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_response_model.dart';

/// UseCase for fetching paginated listings with filtering
class GetListingsUseCase implements BaseUseCase<ListingResponseModel, ListingFilterModel> {
  final ListingRepository repository;

  GetListingsUseCase({required this.repository});

  @override
  Future<Either<Exception, ListingResponseModel>> call(ListingFilterModel filter) {
    return repository.getListings(filter);
  }
}
