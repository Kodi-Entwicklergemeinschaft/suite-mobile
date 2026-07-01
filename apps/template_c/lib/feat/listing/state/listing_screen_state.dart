import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

/// State for [ListingScreenController].
///
/// Differs from [ListingState] (used by home widgets) in that it carries
/// pagination metadata needed for infinite-scroll / load-more behaviour.
class ListingScreenState {
  final StateConstant stateConstant;

  /// Accumulated items across all fetched pages.
  final List<ListingModel> items;

  /// Error message when [stateConstant] is [StateConstant.error].
  final String message;

  /// Filter that produced the current [items].
  final ListingFilterModel filter;

  /// True while the initial page-1 fetch is in flight.
  final bool isRefreshing;

  /// True while a load-more (page > 1) fetch is in flight.
  final bool isLoadingMore;

  /// Whether the API indicated more pages are available.
  final bool hasMore;

  /// The page that was last successfully fetched.
  final int currentPage;

  const ListingScreenState({
    required this.stateConstant,
    this.items = const [],
    this.message = '',
    required this.filter,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  ListingScreenState copyWith({
    StateConstant? stateConstant,
    List<ListingModel>? items,
    String? message,
    ListingFilterModel? filter,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return ListingScreenState(
      stateConstant: stateConstant ?? this.stateConstant,
      items: items ?? this.items,
      message: message ?? this.message,
      filter: filter ?? this.filter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
