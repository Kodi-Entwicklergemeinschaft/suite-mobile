import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/fav/constant/fav_filter_contant.dart';
import 'package:template_c/feat/fav/constant/sort_by.dart';
import 'package:template_c/feat/fav/constant/sort_order.dart';
import 'package:template_c/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_listing_date_request_model.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_c/feat/fav/domain/usecase/get_fav_use_case.dart';
import 'package:template_c/feat/fav/state/fav_state.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:template_c/offline/fav_offline/controller/fav_offline_controller.dart';

final favScreenControllerProvider = NotifierProvider<FavController, FavState>(
  () => FavController(),
);

class FavController extends Notifier<FavState> {
  GetFavUseCase get _getFavUseCase => ref.read(getFavUseCaseProvider);

  /// Returns (categorySlug, subcategorySlug) for the current selection.
  /// If [slug] matches a top-level category → categorySlug only.
  /// If it matches a child → subcategorySlug only.
  ({String? categorySlug, String? childSubcategorySlug}) _resolveSlug(
    String slug,
  ) {
    if (slug.isEmpty) return (categorySlug: null, childSubcategorySlug: null);
    for (final cat in state.dropdownCategories) {
      if (cat.slug == slug) {
        return (categorySlug: slug, childSubcategorySlug: null);
      }
      for (final child in cat.children) {
        if (child.slug == slug) {
          return (categorySlug: null, childSubcategorySlug: slug);
        }
      }
    }
    // Fallback: treat as category slug
    return (categorySlug: slug, childSubcategorySlug: null);
  }

  @override
  FavState build() {
    return FavState(
      StateConstant.loading,
      '',
      [],
      FavSortOption.oldestFirst,
      1,
      false,
      false,
      20,
      false,
      DateTime.now(),
      [],
      StateConstant.loading,
      [],
      '',
      1,
      false,
      false,
      [],
      '',
      [], // dropdownCategories
      false, // switchToOrganizer
    );
  }

  getFavListing() async {
    try {
      state = state.copyWith(stateConstant: StateConstant.loading);
      final slugs = _resolveSlug(state.selectedFavCategory);
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        page: 1,
        sortBy: getSortBy(),
        sortOrder: getSorderOrder(),
        limit: state.limit,
        subcategorySlug: slugs.categorySlug,
        childSubcategorySlug: slugs.childSubcategorySlug,
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('get fav listing fold error: $l');
          state = state.copyWith(
            errorMessage: l.toString(),
            stateConstant: StateConstant.error,
          );
        },
        (r) {
          final items = r.items ?? [];
          state = state.copyWith(
            stateConstant: StateConstant.success,
            listOfFav: items,
            currentPage: 1,
            hasNextPage: r.meta?.hasNextPage ?? false,
            favCategoryList: r.meta?.categories ?? [],
          );
        },
      );
    } catch (error) {
      debugPrint('get fav Listing exception : $error');

      state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: error.toString(),
      );
    }
  }

  loadMoreFav() async {
    if (state.isPaginationLoading || !state.hasNextPage) return;

    try {
      state = state.copyWith(isPaginationLoading: true);

      final nextPage = state.currentPage + 1;
      final slugs = _resolveSlug(state.selectedFavCategory);
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        page: nextPage,
        sortBy: getSortBy(),
        sortOrder: getSorderOrder(),
        limit: state.limit,
        subcategorySlug: slugs.categorySlug,
        childSubcategorySlug: slugs.childSubcategorySlug,
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('load more fav error: $l');
          state = state.copyWith(isPaginationLoading: false);
        },
        (r) {
          final updatedList = [...state.listOfFav, ...?r.items];
          state = state.copyWith(
            listOfFav: updatedList,
            currentPage: nextPage,
            hasNextPage: r.meta?.hasNextPage ?? false,
            isPaginationLoading: false,
          );
        },
      );
    } catch (error) {
      debugPrint('load more fav exception : $error');
      state = state.copyWith(isPaginationLoading: false);
    }
  }

  Future<void> removeFav({required String id}) async {
    await ref
        .read(favouriteToggleServiceProvider)
        .toggleFav(id: id, newValue: false);

    await ref.read(favOfflineControllerProvider.notifier).removeFavItem(id);
  }

  /// Called by [FavouriteToggleService] after a fav toggle succeeds.
  /// - Add: calls getFavListing() to fetch updated list from API.
  /// - Remove: removes locally from both list and calendar view.
  Future<void> updateFavForListing(String id, bool isFav) async {
    if (isFav) {
      await getFavListing();
    } else {
      final mainList = [...state.listOfFav];
      mainList.removeWhere((item) => item.id == id);
      final calendarList = [...state.calendarViewListOfFav];
      calendarList.removeWhere((item) => item.id == id);
      if (mainList.isEmpty && state.selectedFavCategory.isNotEmpty) {
        // Current category emptied out. Refresh the dropdown categories first
        // (the just-emptied one drops off), then decide where to go.
        state = state.copyWith(
          listOfFav: mainList,
          calendarViewListOfFav: calendarList,
          stateConstant: StateConstant.loading,
        );
        await fetchDropdownCategories();

        final remaining = state.dropdownCategories
            .where((c) => c.slug?.isNotEmpty == true)
            .toList();

        if (remaining.isEmpty) {
          // No categories left — tell the screen to switch to organizer.
          state = state.copyWith(
            selectedFavCategory: '',
            switchToOrganizer: true,
          );
        } else {
          // Switch to the first remaining category.
          state = state.copyWith(selectedFavCategory: remaining.first.slug);
          await getFavListing();
        }
      } else {
        final remainingSlugs = {
          ...mainList.map((e) => e.categorySlug).whereType<String>(),
          ...mainList.map((e) => e.subcategorySlug).whereType<String>(),
        };
        final updatedCategories = mainList.isEmpty
            ? <FavCategoryModel>[]
            : state.favCategoryList
                  .where(
                    (c) => c.slug != null && remainingSlugs.contains(c.slug),
                  )
                  .toList();
        final previousSelected = state.selectedFavCategory;
        final selectedStillValid =
            previousSelected.isNotEmpty &&
            updatedCategories.any((c) => c.slug == previousSelected);

        state = state.copyWith(
          listOfFav: mainList,
          calendarViewListOfFav: calendarList,
          favCategoryList: updatedCategories,
          selectedFavCategory: selectedStillValid ? previousSelected : '',
        );
      }
    }
  }

  updateFilter(FavSortOption value) async {
    state = state.copyWith(favSortOption: value);
    await getFavListing();
  }

  SortBy? getSortBy() {
    switch (state.favSortOption) {
      case FavSortOption.oldestFirst || FavSortOption.newestFirst:
        return SortBy.eventStart;
      case FavSortOption.alphabetical:
        return SortBy.title;
    }
  }

  SortOrder? getSorderOrder() {
    switch (state.favSortOption) {
      case FavSortOption.oldestFirst || FavSortOption.alphabetical:
        return SortOrder.asc;
      case FavSortOption.newestFirst:
        return SortOrder.desc;
    }
  }

  updateIsCalendarOpenState(bool isOpen) {
    state = state.copyWith(isCalendarOpen: isOpen);
  }

  updateSelectedDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await getSelectedDateList();
  }

  Future<void> getCalendarViewFavListing() async {
    try {
      state = state.copyWith(calendarViewStateConstant: StateConstant.loading);
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        page: 1,
        sortBy: getSortBy(),
        sortOrder: getSorderOrder(),
        limit: state.limit,
        eventStartFrom: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          00,
          00,
          00,
        ),
        eventStartTo: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          23,
          59,
          59,
        ),
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('get calendar view fav listing fold error: $l');
          state = state.copyWith(
            errorMessage: l.toString(),
            calendarViewStateConstant: StateConstant.error,
          );
        },
        (r) {
          state = state.copyWith(
            calendarViewStateConstant: StateConstant.success,
            calendarViewListOfFav: r.items ?? [],
            calendarViewCurrentPage: 1,
            calendarViewHasNextPage: r.meta?.hasNextPage ?? false,
          );
        },
      );
    } catch (error) {
      debugPrint('get calendar view fav listing fold error: $error');

      state = state.copyWith(
        calendarViewStateConstant: StateConstant.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> getSelectedDateList() async {
    try {
      state = state.copyWith(calendarViewStateConstant: StateConstant.loading);
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        page: 1,
        sortBy: getSortBy(),
        sortOrder: getSorderOrder(),
        limit: state.limit,
        eventStartFrom: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          00,
          00,
          00,
        ),
        eventStartTo: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          23,
          59,
          59,
        ),
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('get calendar view fav listing fold error: $l');
          state = state.copyWith(
            errorMessage: l.toString(),
            calendarViewStateConstant: StateConstant.error,
          );
        },
        (r) {
          state = state.copyWith(
            calendarViewStateConstant: StateConstant.success,
            calendarViewListOfFav: r.items ?? [],
            calendarViewCurrentPage: 1,
            calendarViewHasNextPage: r.meta?.hasNextPage ?? false,
          );
        },
      );
    } catch (error) {
      debugPrint('get calendar view fav listing fold error: $error');

      state = state.copyWith(
        calendarViewStateConstant: StateConstant.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadMoreCalendarViewFav() async {
    if (state.calendarViewIsPaginationLoading || !state.calendarViewHasNextPage)
      return;

    try {
      state = state.copyWith(calendarViewIsPaginationLoading: true);

      final nextPage = state.calendarViewCurrentPage + 1;
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        page: nextPage,
        sortBy: getSortBy(),
        sortOrder: getSorderOrder(),
        limit: state.limit,
        eventStartFrom: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          0,
          0,
          0,
        ),
        eventStartTo: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          23,
          59,
          59,
        ),
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('load more calendar view fav error: $l');
          state = state.copyWith(calendarViewIsPaginationLoading: false);
        },
        (r) {
          final updatedList = [...state.calendarViewListOfFav, ...?r.items];
          state = state.copyWith(
            calendarViewListOfFav: updatedList,
            calendarViewCurrentPage: nextPage,
            calendarViewHasNextPage: r.meta?.hasNextPage ?? false,
            calendarViewIsPaginationLoading: false,
          );
        },
      );
    } catch (error) {
      debugPrint('load more calendar view fav exception: $error');
      state = state.copyWith(calendarViewIsPaginationLoading: false);
    }
  }

  void consumeSwitchToOrganizer() {
    state = state.copyWith(switchToOrganizer: false);
  }

  void clearFavList() {
    state = state.copyWith(
      listOfFav: [],
      currentPage: 1,
      hasNextPage: false,
      selectedFavCategory: '',
      stateConstant: StateConstant.loading,
    );
  }

  /// Updates the active category/subcategory selection and re-fetches.
  ///
  /// [allowToggle] controls re-tap behavior:
  /// - `true` (subcategory chips): re-tapping the active slug clears it,
  ///   falling back to the parent category.
  /// - `false` (dropdown top-level categories): re-tapping always re-applies
  ///   the slug — selecting a category from the dropdown must never deselect.
  updateSelectedCategory(String slug, {bool allowToggle = true}) async {
    final newSlug =
        (allowToggle &&
            state.selectedFavCategory.isNotEmpty &&
            slug == state.selectedFavCategory)
        ? ''
        : slug;
    state = state.copyWith(
      selectedFavCategory: newSlug,
      listOfFav: [],
      currentPage: 1,
      hasNextPage: false,
      stateConstant: StateConstant.loading,
    );
    await getFavListing();
  }

  Future<void> fetchDropdownCategories() async {
    try {
      final result = await _getFavUseCase.getFavCategories();
      result.fold((l) => debugPrint('fetchDropdownCategories error: $l'), (r) {
        final cats = (r.data ?? [])
            .where((c) => c.enabled && c.slug?.isNotEmpty == true)
            .toList();
        state = state.copyWith(dropdownCategories: cats);
      });
    } catch (e) {
      debugPrint('fetchDropdownCategories exception: $e');
    }
  }

  getMonthFavListingDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      GetFavListingDateRequestModel getFavListingDateRequestModel =
          GetFavListingDateRequestModel(startDate: startDate, endDate: endDate);

      final result = await _getFavUseCase.getFavListingDate(
        getFavListingDateRequestModel,
      );

      result.fold(
        (l) {
          debugPrint(' get date list fold exception : ${l.toString()}');
          state = state.copyWith(calendarViewErrorMessage: l.toString());
        },
        (r) {
          state = state.copyWith(dateList: r.data?.dates ?? []);
        },
      );
    } catch (error) {
      debugPrint(' get date list fold exception : ${error.toString()}');
      state = state.copyWith(calendarViewErrorMessage: error.toString());
    }
  }
}
