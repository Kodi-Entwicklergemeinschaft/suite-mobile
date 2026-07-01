import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import '../domain/usecases/get_category_filters_usecase.dart';
import '../state/category_screen_state.dart';

final categoryScreenControllerProvider =
    NotifierProvider.family<CategoryScreenController, CategoryScreenState, String>(
      (slug) => CategoryScreenController(slug),
    );

class CategoryScreenController extends Notifier<CategoryScreenState> {
  final String slug;
  CategoryScreenController(this.slug);

  GetCategoryFiltersUseCase get _useCase =>
      ref.read(getCategoryFiltersUseCaseProvider);

  @override
  CategoryScreenState build() {
    return const CategoryScreenState(stateConstant: StateConstant.loading);
  }

  Future<void> loadCategory() async {
    state = const CategoryScreenState(stateConstant: StateConstant.loading);
    try {
      final result = await _useCase.call(slug);
      result.fold(
        (error) {
          state = CategoryScreenState(
            stateConstant: StateConstant.error,
            message: error.toString(),
          );
        },
        (response) {
          final category =
              response.items.isNotEmpty ? response.items.first : null;
          state = CategoryScreenState(
            stateConstant: StateConstant.success,
            category: category,
          );
        },
      );
    } catch (e, st) {
      state = CategoryScreenState(
        stateConstant: StateConstant.error,
        message: e.toString(),
      );
    }
  }

  void selectFilter(String filterSlug) {
    state = state.copyWith(selectedFilterSlug: filterSlug);
  }

  void clearFilter() {
    state = state.clearFilter();
  }
}
