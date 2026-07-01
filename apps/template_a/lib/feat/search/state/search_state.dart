import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';

class SearchState {
  final StateConstant stateConstant;
  final String errorMessage;
  final List<ListingModel> items;
  final String searchQuery;
  final int currentPage;
  final bool hasNextPage;
  final bool isPaginationLoading;
  final int limit;

  const SearchState({
    this.stateConstant = StateConstant.loading,
    this.errorMessage = '',
    this.items = const [],
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isPaginationLoading = false,
    this.limit = 20,
  });

  SearchState copyWith({
    StateConstant? stateConstant,
    String? errorMessage,
    List<ListingModel>? items,
    String? searchQuery,
    int? currentPage,
    bool? hasNextPage,
    bool? isPaginationLoading,
    int? limit,
  }) {
    return SearchState(
      stateConstant: stateConstant ?? this.stateConstant,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      limit: limit ?? this.limit,
    );
  }
}
