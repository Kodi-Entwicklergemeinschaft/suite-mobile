import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/fav/controller/fav_controller.dart';
import 'package:template_c/feat/fav/data/model/request_model/add_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/remove_fav_request_model.dart';
import 'package:template_c/feat/fav/domain/usecase/add_fav_use_case.dart';
import 'package:template_c/feat/fav/domain/usecase/remove_fav_use_case.dart';
import 'package:template_c/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/controller/listing_detail_controller.dart';
import 'package:template_c/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';

final favouriteToggleServiceProvider = Provider<FavouriteToggleService>(
  (ref) => FavouriteToggleService(ref),
);

/// Centralized service for toggling favourites.
///
/// Calls the add/remove API once, then propagates the [isFavorite] change
/// to every active listing provider locally — eliminating the previous pattern
/// of calling [HomeController.refreshAll] (which fired 10+ GET /listings calls)
/// after every single heart tap.
class FavouriteToggleService {
  final Ref _ref;

  // Guard against rapid double-taps: IDs currently in-flight.
  final _pending = <String>{};

  FavouriteToggleService(this._ref);

  AddFavUseCase get _addFavUseCase => _ref.read(addFavUseCaseProvider);
  RemoveFavUseCase get _removeFavUseCase => _ref.read(removeFavUseCaseProvider);

  /// Toggle favourite for [id] to [newValue].
  ///
  /// No-ops silently if the same ID is already in-flight (double-tap guard).
  Future<void> toggleFav({required String id, required bool newValue}) async {
    if (_pending.contains(id)) {
      log(
        'toggleFav: $id already in-flight, skipping',
        name: 'FavouriteToggleService',
      );
      return;
    }
    _pending.add(id);
    log(
      'toggleFav: ${newValue ? 'ADD' : 'REMOVE'} id=$id',
      name: 'FavouriteToggleService',
    );
    try {
      if (newValue) {
        final result = await _addFavUseCase.call(AddFavRequestModel(id: id));
        result.fold(
          (l) =>
              log('addFav failed id=$id: $l', name: 'FavouriteToggleService'),
          (r) {
            log(
              'addFav success id=$id — broadcasting local update',
              name: 'FavouriteToggleService',
            );
            _broadcastFavChange(id, true);
          },
        );
      } else {
        final result = await _removeFavUseCase.call(
          RemoveFavRequestModel(id: id),
        );
        result.fold(
          (l) => log(
            'removeFav failed id=$id: $l',
            name: 'FavouriteToggleService',
          ),
          (r) {
            log(
              'removeFav success id=$id — broadcasting local update',
              name: 'FavouriteToggleService',
            );
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

  /// Propagates the [isFav] change to all active providers locally.
  void _broadcastFavChange(String id, bool isFav) {
    _updateListingControllers(id, isFav);
    _updateListingScreenControllers(id, isFav);
    _updateListingDetailControllers(id, isFav);
    _updateFavScreen(id, isFav);
    _updateProfile(isFav);
  }

  // ── listingControllerProvider (NOT autoDispose — persists in memory) ─────

  void _updateListingControllers(String id, bool isFav) {
    final homeState = _ref.read(homeControllerProvider);

    final keys = <String>[
      for (final c in homeState.components)
        if (c.visible) ListingFamilyKey.of(c.variant, c.uniqueKey),
      ListingFamilyKey.heute,
      ListingFamilyKey.morgen,
      for (final day in HomeWeekDay.values) ListingFamilyKey.weekDay(day),
      if (homeState.selectedDateRange != null)
        ListingFamilyKey.customRange(homeState.selectedDateRange!),
      // Detail-screen sliders: similar events and more dates per active listing
      for (final key in ListingDetailController.activeKeys) ...[
        ListingFamilyKey.similarEvents(key.id),
        ListingFamilyKey.moreDates(key.id),
      ],
    ];

    for (final key in keys) {
      final provider = listingControllerProvider(key);
      if (_ref.exists(provider)) {
        _ref.read(provider.notifier).updateList(id, isFav);
      }
    }
  }

  // ── listingScreenControllerProvider (autoDispose) ─────────────────────────

  void _updateListingScreenControllers(String id, bool isFav) {
    final homeState = _ref.read(homeControllerProvider);

    // Candidate seeAll keys derived from home components + well-known tabs
    final seeAllKeys = <String>[
      ListingFamilyKey.seeAll(),
      ListingFamilyKey.seeAll('heute'),
      ListingFamilyKey.seeAll('morgen'),
      for (final day in HomeWeekDay.values)
        ListingFamilyKey.seeAll(day.filterKey),
      if (homeState.selectedDateRange != null)
        ListingFamilyKey.seeAll(
          'custom_${_formatDate(homeState.selectedDateRange!.start)}'
          '_${_formatDate(homeState.selectedDateRange!.end)}',
        ),
      for (final c in homeState.components)
        if (c.visible) ListingFamilyKey.seeAll(c.uniqueKey),
      // See All screens opened from listing detail sliders (similar events, more dates)
      for (final key in ListingDetailController.activeKeys) ...[
        ListingFamilyKey.seeAll('similar_${key.id}'),
        ListingFamilyKey.seeAll('more_dates_${key.id}'),
      ],
      // Bottom nav listing tabs (category/subcategory tabs)
      ...BottomNavigationController.activeListingKeys,
    ];

    for (final key in seeAllKeys) {
      final provider = listingScreenControllerProvider(key);
      if (_ref.exists(provider)) {
        _ref.read(provider.notifier).updateFavStatus(id, isFav);
      }
    }
  }

  // ── listingDetailControllerProvider (autoDispose, tracked via static set) ─

  void _updateListingDetailControllers(String id, bool isFav) {
    for (final key in ListingDetailController.activeKeys.toList()) {
      if (key.id == id) {
        final provider = listingDetailControllerProvider(key);
        if (_ref.exists(provider)) {
          log(
            'updateListingDetailController: id=$id isFav=$isFav',
            name: 'FavouriteToggleService',
          );
          _ref.read(provider.notifier).updateFavStatus(isFav);
        }
      }
    }
  }

  // ── favScreenControllerProvider ───────────────────────────────────────────

  void _updateFavScreen(String id, bool isFav) {
    final provider = favScreenControllerProvider;
    if (_ref.exists(provider)) {
      log(
        'updateFavScreen: id=$id isFav=$isFav — ${isFav ? 'refetching list' : 'removing locally'}',
        name: 'FavouriteToggleService',
      );
      _ref.read(provider.notifier).updateFavForListing(id, isFav);
      // Refresh categories only on add — on remove the category list shrinks
      // and the current _selectedSlug would no longer match, breaking the title.
      if (isFav) _ref.read(provider.notifier).fetchDropdownCategories();
    }
  }

  // ── profileControllerProvider (autoDispose) ───────────────────────────────

  void _updateProfile(bool isFav) {
    final provider = profileControllerProvider;
    if (!_ref.exists(provider)) return;
    log(
      'updateProfile: adjusting fav count isFav=$isFav',
      name: 'FavouriteToggleService',
    );
    final current = _ref.read(provider).data;
    if (current != null && current.events != null) {
      final updated = isFav
          ? current.events! + 1
          : (current.events! - 1).clamp(0, double.maxFinite).toInt();
      _ref
          .read(provider.notifier)
          .setProfileData(current.copyWith(events: updated));
    }
    _ref.read(provider.notifier).getProfile();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${pad(d.month)}${pad(d.day)}';
  }
}
