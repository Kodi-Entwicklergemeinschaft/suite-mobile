import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

class ListingState {
  final StateConstant stateConstant;
  final List<ListingModel> listingModel;
  final String message;
  final ListingFilterModel filter;
  final bool isRefreshing;
  final bool hasNextPage;

  ListingState(
    this.stateConstant,
    this.listingModel,
    this.message,
    this.filter, {
    this.isRefreshing = false,
    this.hasNextPage = false,
  });

  ListingState copyWith({
    StateConstant? stateConstant,
    List<ListingModel>? listingModel,
    String? message,
    ListingFilterModel? filter,
    bool? isRefreshing,
    bool? hasNextPage,
  }) {
    return ListingState(
      stateConstant ?? this.stateConstant,
      listingModel ?? this.listingModel,
      message ?? this.message,
      filter ?? this.filter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
