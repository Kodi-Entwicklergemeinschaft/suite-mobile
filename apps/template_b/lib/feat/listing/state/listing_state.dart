import '../data/models/listing_model.dart';
import '../data/models/listing_response_model.dart';
import '../data/models/listing_filter_model.dart';

/// State class for listing list screen
class ListingState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final ListingResponseModel? data;
  final ListingFilterModel filter;
  final int currentPage;

  ListingState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.data,
    required this.filter,
    this.currentPage = 1,
  });

  ListingState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    ListingResponseModel? data,
    ListingFilterModel? filter,
    int? currentPage,
  }) {
    return ListingState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  List<ListingModel> get items => data?.items ?? [];
  bool get hasNextPage => data?.hasNextPage ?? false;
  int get totalListings => data?.total ?? 0;
}

