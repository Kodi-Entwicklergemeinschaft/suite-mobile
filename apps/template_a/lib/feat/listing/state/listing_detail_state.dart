import '../data/models/listing_model.dart';

class ListingDetailState {
  final bool isLoading;
  final String? error;
  final ListingModel? listing;

  ListingDetailState({
    this.isLoading = false,
    this.error,
    this.listing,
  });

  ListingDetailState copyWith({
    bool? isLoading,
    String? error,
    ListingModel? listing,
  }) {
    return ListingDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      listing: listing ?? this.listing,
    );
  }
}
