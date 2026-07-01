import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/fav/controller/fav_category_screen_controller.dart';
import 'package:template_a/feat/fav/controller/fav_controller.dart';
import 'package:template_a/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_a/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_a/feat/fav/domain/usecase/add_fav_use_case.dart';
import 'package:template_a/feat/fav/domain/usecase/remove_fav_use_case.dart';
import 'package:template_a/feat/fav/provider/active_fav_category_keys_provider.dart';
import 'package:template_a/feat/home/controller/home_controller.dart';
import 'package:template_a/feat/listing/controller/listing_controller.dart';
import 'package:template_a/feat/listing/controller/listing_detail_controller.dart';
import 'package:template_a/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_a/feat/listing/provider/active_listing_screen_keys_provider.dart';

final favouriteToggleServiceProvider = Provider<FavouriteToggleService>(
  (ref) => FavouriteToggleService(ref),
);

/// Calls add/remove API once and then propagates the isFavourite change
/// to every active listing provider locally — no extra GET /listings calls.
class FavouriteToggleService {
  final Ref _ref;

  final _pending = <String>{};

  FavouriteToggleService(this._ref);

  AddFavUseCase get _addFavUseCase => _ref.read(addFavUseCaseProvider);
  RemoveFavUseCase get _removeFavUseCase => _ref.read(removeFavUseCaseProvider);

  Future<void> toggleFav({required String id, required bool newValue}) async {
    if (_pending.contains(id)) {
      log('toggleFav: $id already in-flight, skipping', name: 'FavouriteToggleService');
      return;
    }
    _pending.add(id);
    log('toggleFav: ${newValue ? 'ADD' : 'REMOVE'} id=$id', name: 'FavouriteToggleService');
    try {
      if (newValue) {
        final result = await _addFavUseCase.call(AddFavRequestModel(id: id));
        result.fold(
          (l) => log('addFav failed id=$id: $l', name: 'FavouriteToggleService'),
          (r) {
            log('addFav success id=$id', name: 'FavouriteToggleService');
            _broadcastFavChange(id, true);
          },
        );
      } else {
        final result = await _removeFavUseCase.call(RemoveFavRequestModel(id: id));
        result.fold(
          (l) => log('removeFav failed id=$id: $l', name: 'FavouriteToggleService'),
          (r) {
            log('removeFav success id=$id', name: 'FavouriteToggleService');
            _broadcastFavChange(id, false);
          },
        );
      }
    } catch (e) {
      log('toggleFav exception id=$id: $e', name: 'FavouriteToggleService');
    } finally {
      _pending.remove(id);
    }
  }

  void _broadcastFavChange(String id, bool isFav) {
    _updateListingControllers(id, isFav);
    _updateListingScreenControllers(id, isFav);
    _updateListingDetailController(id, isFav);
    _updateFavScreen(id, isFav);
    _updateFavCategoryScreenControllers(id, isFav);
    _updateProfileFavCategories();
  }

  // ── listingControllerProvider (family, NOT autoDispose) ───────────────────

  void _updateListingControllers(String id, bool isFav) {
    final homeState = _ref.read(homeControllerProvider);

    final keys = <String>[
      for (final c in homeState.components)
        if (c.visible)
          c.category?.isNotEmpty == true
              ? c.category!
              : c.label ?? c.variant.value,
    ];

    for (final key in keys) {
      final provider = listingControllerProvider(key);
      if (_ref.exists(provider)) {
        _ref.read(provider.notifier).updateList(id, isFav);
      }
    }
  }

  // ── listingScreenControllerProvider (autoDispose family) ──────────────────

  void _updateListingScreenControllers(String id, bool isFav) {
    final homeState = _ref.read(homeControllerProvider);

    // Keys derived from home config (carousels on home screen)
    final homeKeys = <String>{
      for (final c in homeState.components)
        if (c.visible)
          '${c.category?.isNotEmpty == true ? c.category! : c.label ?? c.variant.value}_category',
    };

    // Keys from any currently-mounted CategoryScreen (discover, fav, etc.)
    final activeKeys = _ref.read(activeListingScreenKeysProvider);

    for (final key in {...homeKeys, ...activeKeys}) {
      final provider = listingScreenControllerProvider(key);
      if (_ref.exists(provider)) {
        _ref.read(provider.notifier).updateFavStatus(id, isFav);
      }
    }
  }

  // ── listingDetailProvider (autoDispose, single instance) ─────────────────

  void _updateListingDetailController(String id, bool isFav) {
    final provider = listingDetailProvider;
    if (_ref.exists(provider)) {
      _ref.read(provider.notifier).updateFavStatus(id, isFav);
    }
  }

  // ── favScreenControllerProvider ───────────────────────────────────────────

  void _updateFavScreen(String id, bool isFav) {
    final provider = favScreenControllerProvider;
    if (_ref.exists(provider)) {
      _ref.read(provider.notifier).updateFavForListing(id, isFav);
    }
  }

  // ── favCategoryScreenProvider (autoDispose family, fromFavorites screens) ─

  void _updateFavCategoryScreenControllers(String id, bool isFav) {
    final activeSlugs = _ref.read(activeFavCategoryKeysProvider);
    for (final slug in activeSlugs) {
      final provider = favCategoryScreenProvider(slug);
      if (_ref.exists(provider)) {
        _ref.read(provider.notifier).updateFavStatus(id, isFav);
      }
    }
  }

  // ── profile fav categories ────────────────────────────────────────────────

  void _updateProfileFavCategories() {
    final provider = favScreenControllerProvider;
    if (_ref.exists(provider)) {
      _ref.read(provider.notifier).getProfileFavCategories();
    }
  }
}
