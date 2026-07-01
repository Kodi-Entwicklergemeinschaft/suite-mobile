import '../data/models/listing_filter_model.dart';

class ListingScreenParams {
  /// Provider family key — matches the key used in [listingScreenControllerProvider].
  final String familyKey;

  /// Title shown in the screen's app bar.
  final String screenTitle;

  /// Filter used for the first page fetch.
  final ListingFilterModel initialFilter;

  const ListingScreenParams({
    required this.familyKey,
    required this.initialFilter,
    this.screenTitle = '',
  });
}
