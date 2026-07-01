import 'package:template_a/core/constant/state_constant.dart';
import '../data/models/listing_filter_model.dart';
import '../data/models/listing_model.dart';

class ListingState {
  final StateConstant stateConstant;
  final List<ListingModel> listingModel;
  final String message;
  final ListingFilterModel filter;
  final bool isRefreshing;

  ListingState(
    this.stateConstant,
    this.listingModel,
    this.message,
    this.filter, {
    this.isRefreshing = false,
  });

  ListingState copyWith({
    StateConstant? stateConstant,
    List<ListingModel>? listingModel,
    String? message,
    bool clearMessage = false,
    ListingFilterModel? filter,
    bool? isRefreshing,
  }) {
    return ListingState(
      stateConstant ?? this.stateConstant,
      listingModel ?? this.listingModel,
      clearMessage ? '' : (message ?? this.message),
      filter ?? this.filter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
