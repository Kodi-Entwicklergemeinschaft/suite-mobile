import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_a/feat/listing/domain/usecases/get_listings_usecase.dart';
import 'package:template_a/feat/search/state/search_state.dart';

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(
  () => SearchController(),
);

class SearchController extends Notifier<SearchState> {
  GetListingsUseCase get _useCase => ref.read(getListingsUseCaseProvider);

  @override
  SearchState build() {
    return const SearchState(stateConstant: StateConstant.loading);
  }

  void reset() {
    state = const SearchState(
      stateConstant: StateConstant.success,
      items: [],
      searchQuery: '',
    );
  }

  void updateSearchQuery(String query) {
    state = const SearchState(stateConstant: StateConstant.loading).copyWith(
      searchQuery: query,
    );
    _fetchPage(1, replace: true);
  }

  Future<void> search() async {
    await _fetchPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (state.isPaginationLoading || !state.hasNextPage) return;
    await _fetchPage(state.currentPage + 1, replace: false);
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    final filter = ListingFilterModel(
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      page: page,
      limit: state.limit,
    );

    if (replace) {
      state = state.copyWith(
        stateConstant: StateConstant.loading,
        items: [],
        currentPage: 0,
        isPaginationLoading: false,
      );
    } else {
      state = state.copyWith(isPaginationLoading: true);
    }

    try {
      final result = await _useCase.call(filter);
      if (!ref.mounted) return;

      result.fold(
        (error) {
          state = state.copyWith(
            stateConstant: StateConstant.error,
            errorMessage: error.toString(),
            isPaginationLoading: false,
          );
        },
        (response) {
          final newItems = response.items ?? [];
          final merged = replace ? newItems : [...state.items, ...newItems];
          final hasMore = response.meta?.hasNextPage ?? newItems.isNotEmpty;

          state = state.copyWith(
            stateConstant: StateConstant.success,
            items: merged,
            currentPage: page,
            hasNextPage: hasMore,
            isPaginationLoading: false,
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: e.toString(),
        isPaginationLoading: false,
      );
    }
  }
}
