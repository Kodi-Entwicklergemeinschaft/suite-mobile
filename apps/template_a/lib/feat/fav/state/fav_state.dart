import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/fav/data/model/response_model/fav_category_model.dart';
import 'package:template_a/feat/fav/data/model/response_model/fav_profile_category_model.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';

class FavState {
  final StateConstant stateConstant;
  final String errorMessage;
  final List<ListingModel> listOfFav;
  final String selectedFavCategory;
  final List<FavCategoryModel> favCategoryList;
  final int currentPage;
  final bool hasNextPage;
  final bool isPaginationLoading;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  // Profile favourites categories (from /me/favorites/categories endpoint)
  final List<FavProfileCategoryModel> profileFavCategories;
  final bool isProfileCategoriesLoading;
  // True after the first fetch completes (even if the result is empty).
  // Prevents the profile screen from re-triggering the load on every rebuild.
  final bool hasLoadedProfileCategories;

  const FavState({
    this.stateConstant = StateConstant.loading,
    this.errorMessage = '',
    this.listOfFav = const [],
    this.selectedFavCategory = '',
    this.favCategoryList = const [],
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isPaginationLoading = false,
    this.filterStartDate,
    this.filterEndDate,
    this.profileFavCategories = const [],
    this.isProfileCategoriesLoading = false,
    this.hasLoadedProfileCategories = false,
  });

  bool get isEventCategory => selectedFavCategory.contains('event');

  FavState copyWith({
    StateConstant? stateConstant,
    String? errorMessage,
    List<ListingModel>? listOfFav,
    String? selectedFavCategory,
    List<FavCategoryModel>? favCategoryList,
    int? currentPage,
    bool? hasNextPage,
    bool? isPaginationLoading,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
    List<FavProfileCategoryModel>? profileFavCategories,
    bool? isProfileCategoriesLoading,
    bool? hasLoadedProfileCategories,
  }) {
    return FavState(
      stateConstant: stateConstant ?? this.stateConstant,
      errorMessage: errorMessage ?? this.errorMessage,
      listOfFav: listOfFav ?? this.listOfFav,
      selectedFavCategory: selectedFavCategory ?? this.selectedFavCategory,
      favCategoryList: favCategoryList ?? this.favCategoryList,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      filterStartDate: clearStartDate ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearEndDate ? null : (filterEndDate ?? this.filterEndDate),
      profileFavCategories: profileFavCategories ?? this.profileFavCategories,
      isProfileCategoriesLoading:
          isProfileCategoriesLoading ?? this.isProfileCategoriesLoading,
      hasLoadedProfileCategories:
          hasLoadedProfileCategories ?? this.hasLoadedProfileCategories,
    );
  }
}
