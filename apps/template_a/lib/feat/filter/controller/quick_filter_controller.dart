import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import '../data/repositories/quick_filter_repository.dart';
import 'quick_filter_state.dart';

final quickFilterControllerProvider =
    NotifierProvider.family<QuickFilterController, QuickFilterState, String>(
  (slug) => QuickFilterController(slug),
);

class QuickFilterController extends Notifier<QuickFilterState> {
  final String categorySlug;
  QuickFilterController(this.categorySlug);

  QuickFilterRepository get _repo => ref.read(quickFilterRepositoryProvider);

  @override
  QuickFilterState build() => const QuickFilterState();

  Future<void> loadFilters() async {
    if (categorySlug.isEmpty) return;
    state = state.copyWith(stateConstant: StateConstant.loading);
    final result = await _repo.getQuickFilters(categorySlug);
    result.fold(
      (error) => state = state.copyWith(
        stateConstant: StateConstant.error,
        message: error.toString(),
      ),
      (response) => state = state.copyWith(
        stateConstant: StateConstant.success,
        filterGroups: response.groups,
      ),
    );
  }

  void applyFilters(List<String> ids) {
    state = state.copyWith(selectedFilterIds: ids);
  }

  void resetFilters() {
    state = state.copyWith(selectedFilterIds: []);
  }
}
