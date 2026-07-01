import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/data/models/listing_media_model.dart';
import 'package:template_c/feat/listing/domain/usecases/get_listing_detail_usecase.dart';
import 'package:template_c/feat/listing/state/listing_detail_state.dart';

/// Family key is a record of (listingId, sourceKey) so each originating
/// ListingWidget context gets its own isolated provider instance.
final listingDetailControllerProvider = NotifierProvider.autoDispose
    .family<
      ListingDetailController,
      ListingDetailState,
      ({String id, String familyKey})
    >((params) => ListingDetailController(params.id, params));

class ListingDetailController extends Notifier<ListingDetailState> {
  final String listingId;
  final ({String id, String familyKey}) _arg;

  /// Tracks all currently alive detail controller instances so the
  /// FavouriteToggleService can update them locally by listing ID.
  static final activeKeys = <({String id, String familyKey})>{};

  ListingDetailController(this.listingId, this._arg);

  GetListingDetailUseCase get _useCase =>
      ref.read(getListingDetailUseCaseProvider);

  @override
  ListingDetailState build() {
    activeKeys.add(_arg);
    ref.onDispose(() => activeKeys.remove(_arg));
    Future.microtask(_fetch);
    return const ListingDetailState(stateConstant: StateConstant.loading);
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(stateConstant: StateConstant.loading);
    await _fetch();
  }

  Future<void> _fetch() async {
    log('fetchDetail: $listingId', name: 'ListingDetailController');

    try {
      // TODO: Remove dummy model and uncomment API call
      // final dummyListing = _getDummyListing();

      // if (!ref.mounted) return;

      // log('success: ${dummyListing.title}', name: 'ListingDetailController');
      // state = state.copyWith(
      //   stateConstant: StateConstant.success,
      //   listing: dummyListing,
      // );

      // Uncomment below to use real API:

      final result = await _useCase.call(
        GetListingDetailParams(listingId: listingId),
      );

      if (!ref.mounted) return;

      result.fold(
        (error) {
          log('error: $error', name: 'ListingDetailController');
          state = state.copyWith(
            stateConstant: StateConstant.error,
            message: error.toString(),
          );
        },
        (listing) {
          log('success: ${listing.title}', name: 'ListingDetailController');
          state = state.copyWith(
            stateConstant: StateConstant.success,
            listing: listing,
          );
        },
      );
    } catch (e) {
      log('exception: $e', name: 'ListingDetailController');
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        message: e.toString(),
      );
    }
  }

  Future<void> toggleFav() async {
    final listing = state.listing;
    if (listing?.id == null) return;
    final isFav = listing!.isFavorite ?? false;
    await ref
        .read(favouriteToggleServiceProvider)
        .toggleFav(id: listing.id!, newValue: !isFav);
  }

  /// Called by [FavouriteToggleService] to update this detail view locally.
  void updateFavStatus(bool isFav) {
    state = state.copyWith(
      listing: state.listing?.copyWith(isFavorite: isFav),
    );
  }

}
