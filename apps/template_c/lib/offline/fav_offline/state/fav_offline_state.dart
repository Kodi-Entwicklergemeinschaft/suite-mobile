import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

class FavOfflineState {
  List<ListingModel> listingModelList;
  List<String> unselectedFavList;
  StateConstant stateConstant;
  FavOfflineState(
    this.listingModelList,
    this.unselectedFavList,
    this.stateConstant,
  );

  FavOfflineState copyWith({
    List<ListingModel>? listingModelList,
    List<String>? unselectedFavList,
    StateConstant? stateConstant,
  }) {
    return FavOfflineState(
      listingModelList ?? this.listingModelList,
      unselectedFavList ?? this.unselectedFavList,
      stateConstant ?? this.stateConstant,
    );
  }
}
