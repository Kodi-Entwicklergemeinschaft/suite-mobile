import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/domain/usecase/get_fav_categories_use_case.dart';
import 'package:template_a/feat/fav/domain/usecase/get_fav_use_case.dart';
import 'package:template_a/feat/fav/state/fav_state.dart';

final favScreenControllerProvider = NotifierProvider<FavController, FavState>(
  () => FavController(),
);

class FavController extends Notifier<FavState> {
  GetFavUseCase get _getFavUseCase => ref.read(getFavUseCaseProvider);

  @override
  FavState build() => const FavState();

  Future<void> getFavListing({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) async {
    final newCategory = category ?? state.selectedFavCategory;
    final newStart = clearDates ? null : (startDate ?? state.filterStartDate);
    final newEnd = clearDates ? null : (endDate ?? state.filterEndDate);

    state = state.copyWith(
      stateConstant: StateConstant.loading,
      selectedFavCategory: newCategory,
      filterStartDate: newStart,
      filterEndDate: newEnd,
      clearStartDate: clearDates,
      clearEndDate: clearDates,
    );
    try {
      final result = await _getFavUseCase.call(GetFavRequestModel(
        page: 1,
        limit: 20,
        categorySlug: state.selectedFavCategory.isNotEmpty
            ? state.selectedFavCategory
            : null,
        eventStartFrom: state.filterStartDate?.toUtc().toIso8601String(),
        eventStartTo: state.filterEndDate?.toUtc().toIso8601String(),
      ));
      if (!ref.mounted) return;
      result.fold(
        (l) => state = state.copyWith(
          stateConstant: StateConstant.error,
          errorMessage: l.toString(),
        ),
        (r) => state = state.copyWith(
          stateConstant: StateConstant.success,
          listOfFav: r.items ?? [],
          currentPage: 1,
          hasNextPage: r.meta?.hasNextPage ?? false,
          favCategoryList: r.meta?.categories ?? state.favCategoryList,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreFav() async {
    if (state.isPaginationLoading || !state.hasNextPage) return;
    state = state.copyWith(isPaginationLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _getFavUseCase.call(GetFavRequestModel(
        page: nextPage,
        limit: 20,
        categorySlug: state.selectedFavCategory.isNotEmpty
            ? state.selectedFavCategory
            : null,
      ));
      if (!ref.mounted) return;
      result.fold(
        (l) => state = state.copyWith(isPaginationLoading: false),
        (r) => state = state.copyWith(
          listOfFav: [...state.listOfFav, ...?r.items],
          currentPage: nextPage,
          hasNextPage: r.meta?.hasNextPage ?? false,
          isPaginationLoading: false,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isPaginationLoading: false);
    }
  }

  Future<void> removeFav(String id) async {
    await ref
        .read(favouriteToggleServiceProvider)
        .toggleFav(id: id, newValue: false);
  }

  Future<void> selectCategory(String slug) async {
    final newCategory = state.selectedFavCategory == slug ? '' : slug;
    // Reset date filters when switching category
    await getFavListing(category: newCategory, clearDates: true);
  }

  Future<void> getProfileFavCategories() async {
    if (state.isProfileCategoriesLoading) return;
    state = state.copyWith(isProfileCategoriesLoading: true);
    try {
      final result = await ref.read(getFavCategoriesUseCaseProvider).call();
      if (!ref.mounted) return;
      result.fold(
        (l) => state = state.copyWith(
          isProfileCategoriesLoading: false,
          hasLoadedProfileCategories: true,
        ),
        (r) => state = state.copyWith(
          isProfileCategoriesLoading: false,
          hasLoadedProfileCategories: true,
          profileFavCategories: r.data ?? [],
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isProfileCategoriesLoading: false,
        hasLoadedProfileCategories: true,
      );
    }
  }

  /// Called by [FavouriteToggleService] after a toggle succeeds.
  Future<void> updateFavForListing(String id, bool isFav) async {
    if (isFav) {
      await getFavListing(clearDates: true);
    } else {
      final updated = state.listOfFav.where((item) => item.id != id).toList();
      state = state.copyWith(listOfFav: updated);
    }
  }
}
