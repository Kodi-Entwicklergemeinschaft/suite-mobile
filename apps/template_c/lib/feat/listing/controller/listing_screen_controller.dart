import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/domain/usecases/get_listings_usecase.dart';
import 'package:template_c/feat/listing/state/listing_screen_state.dart';

/// Family key: a plain [String] — consistent with [listingControllerProvider].
/// Example: `"seeAll_events"`, `"seeAll_events_heute"`
final listingScreenControllerProvider = NotifierProvider.autoDispose
    .family<ListingScreenController, ListingScreenState, String>(
      (familyKey) => ListingScreenController(familyKey),
    );

class ListingScreenController extends Notifier<ListingScreenState> {
  final String familyKey;

  ListingScreenController(this.familyKey);

  GetListingsUseCase get _useCase => ref.read(getListingUseCaseProvider);

  @override
  ListingScreenState build() {
    return ListingScreenState(
      stateConstant: StateConstant.loading,
      filter: ListingFilterModel(page: 1),
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Initial fetch — called from [ListingScreen.initState] with the
  /// filter built from [ListingScreenParams.initialFilter].
  /// Mirrors [ListingController.getListing].
  Future<void> getListing(ListingFilterModel filter) async {
    await _fetchPage(1, replace: true, filterOverride: filter);
  }

  /// Load the next page. No-ops when already loading or no more pages.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isRefreshing) return;
    if (!state.hasMore) return;
    if (state.stateConstant == StateConstant.loading) return;
    await _fetchPage(state.currentPage + 1, replace: false);
  }

  /// Pull-to-refresh — resets to page 1, keeps active filter.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, hasMore: true);
    await _fetchPage(1, replace: true, filterOverride: state.filter);
  }

  /// Apply an arbitrary filter and restart from page 1.
  Future<void> applyFilter(ListingFilterModel newFilter) async {
    state = state.copyWith(
      stateConstant: StateConstant.loading,
      items: [],
      filter: newFilter,
      hasMore: true,
      currentPage: 0,
    );
    await _fetchPage(1, replace: true, filterOverride: newFilter);
  }

  // ── Favouriting ────────────────────────────────────────────────────────────

  Future<void> addFav({required String id}) async {
    await ref
        .read(favouriteToggleServiceProvider)
        .toggleFav(id: id, newValue: true);
  }

  Future<void> removeFav({required String id}) async {
    await ref
        .read(favouriteToggleServiceProvider)
        .toggleFav(id: id, newValue: false);
  }

  /// Called by [FavouriteToggleService] to update this screen's list locally.
  void updateFavStatus(String id, bool isFav) {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final updated = [...state.items];
    updated[index] = updated[index].copyWith(isFavorite: isFav);
    state = state.copyWith(items: updated);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _fetchPage(
    int page, {
    required bool replace,
    ListingFilterModel? filterOverride,
  }) async {
    // Preserve the active filter for load-more / refresh.
    // Store only the base filter (without injected device values) so that
    // refresh() always re-resolves lat/long/eventStartFrom from current prefs.
    final baseFilter = filterOverride ?? state.filter;
    final baseWithPage = baseFilter.copyWith(page: page);

    final pref = ref.read(preferenceManagerProvider);
    final filter = injectDeviceValues(baseWithPage, pref);

    log(
      'familyKey : $familyKey\nqueryPath : ${filter.toDebugUri()}',
      name: 'ListingScreenController',
    );

    if (replace) {
      state = state.copyWith(
        stateConstant: StateConstant.loading,
        filter: baseWithPage, // store base, not injected
        items: [],
        currentPage: 0,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, filter: baseWithPage);
    }

    try {
      final result = await _useCase.call(filter);

      if (!ref.mounted) return;

      result.fold(
        (error) {
          log(
            'error [$familyKey] p$page: $error',
            name: 'ListingScreenController',
          );
          state = state.copyWith(
            stateConstant: StateConstant.error,
            message: error.toString(),
            isRefreshing: false,
            isLoadingMore: false,
          );
        },
        (response) {
          final newItems = response.items ?? [];
          final merged = replace ? newItems : [...state.items, ...newItems];
          final hasMore = response.meta?.hasNextPage ?? newItems.isNotEmpty;

          log(
            'success [$familyKey] p$page: ${newItems.length} items, hasMore=$hasMore',
            name: 'ListingScreenController',
          );

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
      log('exception [$familyKey] p$page: $e', name: 'ListingScreenController');
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
