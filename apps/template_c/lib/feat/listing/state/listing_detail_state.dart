import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

class ListingDetailState {
  final StateConstant stateConstant;
  final ListingModel? listing;
  final String message;

  const ListingDetailState({
    required this.stateConstant,
    this.listing,
    this.message = '',
  });

  ListingDetailState copyWith({
    StateConstant? stateConstant,
    ListingModel? listing,
    String? message,
  }) {
    return ListingDetailState(
      stateConstant: stateConstant ?? this.stateConstant,
      listing: listing ?? this.listing,
      message: message ?? this.message,
    );
  }
}
