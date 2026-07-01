import 'package:template_a/core/constant/state_constant.dart';
import '../data/models/listing_filter_model.dart';
import '../data/models/listing_model.dart';

class ListingScreenState {
  final StateConstant stateConstant;
  final List<ListingModel> items;
  final String message;
  final ListingFilterModel filter;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
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
