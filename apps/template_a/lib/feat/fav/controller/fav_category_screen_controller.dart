import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_a/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_a/feat/fav/domain/usecase/get_fav_use_case.dart';
import 'package:template_a/feat/fav/state/fav_category_state.dart';

final favCategoryScreenProvider =
    NotifierProvider.family<FavCategoryScreenController, FavCategoryState, String>(
  (slug) => FavCategoryScreenController(slug),
);

class FavCategoryScreenController extends Notifier<FavCategoryState> {
  final String categorySlug;

  FavCategoryScreenController(this.categorySlug);

  GetFavUseCase get _useCase => ref.read(getFavUseCaseProvider);

  @override
  FavCategoryState build() => const FavCategoryState();

  Future<void> load({String? subCategory}) async {
    final effectiveSlug =
        subCategory != null && subCategory.isNotEmpty ? subCategory : categorySlug;
    state = state.copyWith(
      stateConstant: StateConstant.loading,
      selectedSubCategory: subCategory ?? '',
    );
    try {
      final result = await _useCase.call(
        GetFavRequestModel(page: 1, limit: 20, categorySlug: effectiveSlug),
      );
      if (!ref.mounted) return;
      result.fold(
        (l) => state = state.copyWith(
          stateConstant: StateConstant.error,
          errorMessage: l.toString(),
        ),
        (r) {
          // Subcategory chips = every category returned except the primary slug itself.
          final subs = (r.meta?.categories ?? [])
              .where((c) => c.slug != categorySlug)
              .toList();
          state = state.copyWith(
            stateConstant: StateConstant.success,
            items: r.items ?? [],
            subCategories: state.subCategories.isEmpty ? subs : state.subCategories,
            currentPage: 1,
            hasNextPage: r.meta?.hasNextPage ?? false,
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isPaginationLoading || !state.hasNextPage) return;
    state = state.copyWith(isPaginationLoading: true);
    try {
      final effectiveSlug = state.selectedSubCategory.isNotEmpty
          ? state.selectedSubCategory
          : categorySlug;
      final nextPage = state.currentPage + 1;
      final result = await _useCase.call(
        GetFavRequestModel(page: nextPage, limit: 20, categorySlug: effectiveSlug),
      );
      if (!ref.mounted) return;
      result.fold(
        (l) => state = state.copyWith(isPaginationLoading: false),
        (r) => state = state.copyWith(
          items: [...state.items, ...?r.items],
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

  Future<void> selectSubCategory(String slug) async {
    final newSub = state.selectedSubCategory == slug ? '' : slug;
    await load(subCategory: newSub.isEmpty ? null : newSub);
  }

  Future<void> removeFav(String id) async {
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
    await ref.read(favouriteToggleServiceProvider).toggleFav(id: id, newValue: false);
  }

  void updateFavStatus(String id, bool isFav) {
    if (!isFav) {
      state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
    }
  }
}
