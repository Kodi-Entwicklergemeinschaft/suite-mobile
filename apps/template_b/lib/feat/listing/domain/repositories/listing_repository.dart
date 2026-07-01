import 'package:network/network.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/listing_response_model.dart';
import '../../data/models/listing_filter_config_response_model.dart';

/// Abstract repository for listing operations
/// Note: tenantId is passed automatically via HeaderInterceptor from preferences
abstract class ListingRepository {
  /// Get paginated list of listings with filtering
  Future<Either<Exception, ListingResponseModel>> getListings(
    ListingFilterModel filter,
  );

  /// Get single listing by ID
  Future<Either<Exception, ListingModel>> getListingById(
    String listingId,
  );

  /// Get single listing by slug
  Future<Either<Exception, ListingModel>> getListingBySlug(
    String slug,
  );

  /// Get filter configuration for a category slug
  Future<Either<Exception, ListingFilterConfigResponseModel>> getFilterConfig(
    String categorySlug,
  );
}
