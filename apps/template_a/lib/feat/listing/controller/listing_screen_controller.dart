import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/utils/location_service.dart';
import '../data/models/listing_filter_model.dart';
import '../data/models/listing_model.dart';
import '../domain/usecases/get_listings_usecase.dart';
import '../state/listing_screen_state.dart';

final listingScreenControllerProvider = NotifierProvider.autoDispose
    .family<ListingScreenController, ListingScreenState, String>(
      (familyKey) => ListingScreenController(familyKey),
    );

class ListingScreenController extends Notifier<ListingScreenState> {
  final String familyKey;
  ListingScreenController(this.familyKey);

  GetListingsUseCase get _useCase => ref.read(getListingsUseCaseProvider);

  @override
  ListingScreenState build() {
    return ListingScreenState(
      stateConstant: StateConstant.loading,
      filter: ListingFilterModel(page: 1),
    );
  }

  Future<(double?, double?)> _getCurrentLocation() async {
    final position = await LocationService().getCurrentLocation();
    return (position?.latitude, position?.longitude);
  }

  List<ListingModel> _attachDistances(List<ListingModel> items, double? userLat, double? userLng) {
    if (userLat == null || userLng == null) return items;
    return items.map((item) {
      if (item.geoLat == null || item.geoLng == null) return item;
      final meters = Geolocator.distanceBetween(
        userLat, userLng, item.geoLat!, item.geoLng!,
      );
      return item.copyWith(distance: meters);
    }).toList();
  }

  Future<void> getListing(ListingFilterModel filter) async {
    final (userLat, userLng) = await _getCurrentLocation();
    final enrichedFilter = filter.radiusMeters != null
        ? filter.copyWith(latitude: userLat, longitude: userLng)
        : filter;
    await _fetchPage(1, replace: true, filterOverride: enrichedFilter, userLat: userLat, userLng: userLng);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isRefreshing) return;
    if (!state.hasMore) return;
    if (state.stateConstant == StateConstant.loading) return;
    final (userLat, userLng) = await _getCurrentLocation();
    await _fetchPage(state.currentPage + 1, replace: false, userLat: userLat, userLng: userLng);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    final (userLat, userLng) = await _getCurrentLocation();
    state = state.copyWith(isRefreshing: true, hasMore: true);
    final enrichedFilter = state.filter.radiusMeters != null
        ? state.filter.copyWith(latitude: userLat, longitude: userLng)
        : state.filter;
    await _fetchPage(1, replace: true, filterOverride: enrichedFilter, userLat: userLat, userLng: userLng);
  }

  void updateFavStatus(String id, bool isFav) {
    final updated = state.items.map((item) {
      return item.id == id ? item.copyWith(isFavourite: isFav) : item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> applyFilter(ListingFilterModel newFilter) async {
    final (userLat, userLng) = await _getCurrentLocation();
    final enrichedFilter = newFilter.radiusMeters != null
        ? newFilter.copyWith(latitude: userLat, longitude: userLng)
        : newFilter;
    state = state.copyWith(
      stateConstant: StateConstant.loading,
      items: [],
      filter: enrichedFilter,
      hasMore: true,
      currentPage: 0,
    );
    await _fetchPage(1, replace: true, filterOverride: enrichedFilter, userLat: userLat, userLng: userLng);
  }

  Future<void> _fetchPage(
    int page, {
    required bool replace,
    ListingFilterModel? filterOverride,
    double? userLat,
    double? userLng,
  }) async {
    final filter = (filterOverride ?? state.filter).copyWith(page: page);

    if (replace) {
      state = state.copyWith(
        stateConstant: StateConstant.loading,
        filter: filter,
        items: [],
        currentPage: 0,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, filter: filter);
    }

    try {
      final result = await _useCase.call(filter);
      if (!ref.mounted) return;
      result.fold(
        (error) {
          state = state.copyWith(
            stateConstant: StateConstant.error,
            message: error.toString(),
            isRefreshing: false,
            isLoadingMore: false,
          );
        },
        (response) {
          final rawItems = response.items ?? [];
          final withDistance = _attachDistances(rawItems, userLat, userLng);
          final merged = replace ? withDistance : [...state.items, ...withDistance];
          final hasMore = response.meta?.hasNextPage ?? rawItems.isNotEmpty;
          state = state.copyWith(
            stateConstant: StateConstant.success,
            items: merged,
            currentPage: page,
            hasMore: hasMore,
            isRefreshing: false,
            isLoadingMore: false,
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        message: e.toString(),
        isRefreshing: false,
        isLoadingMore: false,
      );
    }
  }
}
