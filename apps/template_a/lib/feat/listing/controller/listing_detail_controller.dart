import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:template_a/core/utils/location_service.dart';
import '../data/models/listing_model.dart';
import '../domain/usecases/get_listing_detail_usecase.dart';
import '../state/listing_detail_state.dart';

final listingDetailProvider =
    NotifierProvider.autoDispose<ListingDetailNotifier, ListingDetailState>(
  ListingDetailNotifier.new,
);

class ListingDetailNotifier extends Notifier<ListingDetailState> {
  @override
  ListingDetailState build() => ListingDetailState();

  void initListing(ListingModel listing) {
    state = state.copyWith(listing: listing);
  }

  void updateFavStatus(String id, bool isFav) {
    if (state.listing?.id == id) {
      state = state.copyWith(listing: state.listing!.copyWith(isFavourite: isFav));
    }
  }

  Future<void> fetchListing(String id, {bool bySlug = false, String? categorySlug}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usecase = ref.read(getListingDetailUseCaseProvider);
      final results = await Future.wait([
        usecase.call(GetListingDetailParams(listingId: id, bySlug: bySlug, categorySlug: categorySlug)),
        LocationService().getCurrentLocation(),
      ]);
      if (!ref.mounted) return;

      final apiResult = results[0] as dynamic;
      final position = results[1] as Position?;

      apiResult.fold(
        (error) => state = state.copyWith(isLoading: false, error: error.toString()),
        (listing) {
          ListingModel enriched = listing as ListingModel;
          if (position != null && enriched.geoLat != null && enriched.geoLng != null) {
            final meters = Geolocator.distanceBetween(
              position.latitude, position.longitude,
              enriched.geoLat!, enriched.geoLng!,
            );
            enriched = enriched.copyWith(distance: meters);
          }
          state = state.copyWith(isLoading: false, listing: enriched);
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
