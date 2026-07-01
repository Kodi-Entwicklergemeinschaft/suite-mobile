import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/domain/usecases/get_listings_usecase.dart';
import 'package:template_c/feat/listing/state/listing_state.dart';

/// Family key format: "{variant}" or "{variant}_{filterKey}" e.g. "content_slider_v2_heute"
/// Each unique key gets its own provider instance with its own state and filter.
/// Uses autoDispose so the controller is disposed when no longer used.
final listingControllerProvider =
    NotifierProvider.family<ListingController, ListingState, String>(
      (familyKey) => ListingController(familyKey),
    );

class ListingController extends Notifier<ListingState> {
  final String familyKey;

  ListingController(this.familyKey);

  GetListingsUseCase get _listingUseCase => ref.read(getListingUseCaseProvider);

  @override
  ListingState build() {
    final initialFilter = ListingFilterModel(limit: 10);
    return ListingState(StateConstant.loading, [], '', initialFilter);
  }

  Future<void> getListing(ListingFilterModel filter) async {
    state = state.copyWith(
      stateConstant: StateConstant.loading,
      filter: filter,
    );

    final pref = ref.read(preferenceManagerProvider);
    filter = injectDeviceValues(filter, pref);

    log(
      'familyKey : $familyKey\nqueryPath : ${filter.toDebugUri()}',
      name: 'ListingController',
    );

    try {
      final result = await _listingUseCase.call(filter);

      if (!ref.mounted) return;

      result.fold(
        (error) {
          log('error [$familyKey]: $error', name: 'ListingController');
          state = state.copyWith(
            stateConstant: StateConstant.error,
            message: error.toString(),
          );
        },
        (response) {
          log(
            'success [$familyKey]: ${response.items?.length} items',
            name: 'ListingController',
          );
          state = state.copyWith(
            stateConstant: StateConstant.success,
            listingModel: response.items ?? [],
            hasNextPage: response.hasNextPage,
          );
        },
      );
    } catch (error) {
      log('exception [$familyKey]: $error', name: 'ListingController');
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        message: error.toString(),
      );
    }
  }

  /// Update filter and re-fetch — each provider instance has its own filter
  Future<void> updateFilter(ListingFilterModel filter) async {
    await getListing(filter);
  }

  /// Re-fetch using the current filter (pull-to-refresh).
  /// Keeps existing items visible while fetching — no shimmer flash.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    var filter = state.filter;
    final pref = ref.read(preferenceManagerProvider);
    filter = injectDeviceValues(filter, pref);

    try {
      final result = await _listingUseCase.call(filter);

      if (!ref.mounted) return;

      result.fold(
        (error) {
          log('refresh error [$familyKey]: $error', name: 'ListingController');
          state = state.copyWith(
            stateConstant: StateConstant.error,
            isRefreshing: false,
          );
        },
        (response) {
          log(
            'refresh success [$familyKey]: ${response.items?.length} items',
            name: 'ListingController',
          );
          state = state.copyWith(
            stateConstant: StateConstant.success,
            listingModel: response.items ?? [],
            hasNextPage: response.hasNextPage,
            isRefreshing: false,
          );
        },
      );
    } catch (error) {
      log('refresh exception [$familyKey]: $error', name: 'ListingController');
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        isRefreshing: false,
      );
    }
  }

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

  Future<void> updateList(String id, bool isFav) async {
    final index = state.listingModel.indexWhere((item) => item.id == id);
    if (index == -1) return;

    debugPrint('id fav status changed = $id');
    final updatedListing = [...state.listingModel];
    updatedListing[index] = updatedListing[index].copyWith(isFavorite: isFav);

    state = state.copyWith(listingModel: updatedListing);
  }
}
