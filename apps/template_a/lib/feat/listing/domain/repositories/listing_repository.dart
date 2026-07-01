import 'package:network/network.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/listing_response_model.dart';

abstract class ListingRepository {
  Future<Either<Exception, ListingResponseModel>> getListings(
    ListingFilterModel filter,
  );

  Future<Either<Exception, ListingModel>> getListingById(String listingId, {String? categorySlug});

  Future<Either<Exception, ListingModel>> getListingBySlug(String slug);
}
