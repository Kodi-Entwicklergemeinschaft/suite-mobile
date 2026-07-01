import '../data/models/listing_model.dart';

/// State class for listing detail screen
class ListingDetailState {
  final bool isLoading;
  final String? error;
  final ListingModel? listing;
  final bool isFavorited;

  ListingDetailState({
    this.isLoading = false,
    this.error,
    this.listing,
    this.isFavorited = false,
  });

  ListingDetailState copyWith({
    bool? isLoading,
    String? error,
    ListingModel? listing,
    bool? isFavorited,
  }) {
    return ListingDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      listing: listing ?? this.listing,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  bool get isEmpty => listing == null;
  bool get isNotEmpty => !isEmpty;
}
