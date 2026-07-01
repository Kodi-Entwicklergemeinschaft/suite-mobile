import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/fav/constant/fav_filter_contant.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_listing_date_response_model.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_response_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

class FavState {
  StateConstant stateConstant;
  String errorMessage;
  List<ListingModel> listOfFav;
  FavSortOption favSortOption;
  int currentPage;
  bool hasNextPage;
  bool isPaginationLoading;
  int limit;
  bool isCalendarOpen;
  DateTime selectedDate;
  List<ListingModel> calendarViewListOfFav;
  StateConstant calendarViewStateConstant;
  List<FavCategoryModel> favCategoryList;
  String selectedFavCategory;
  int calendarViewCurrentPage;
  bool calendarViewHasNextPage;
  bool calendarViewIsPaginationLoading;
  List<String> dateList;
  String calendarViewErrorMessage;
  // Categories from dedicated /favorites/categories endpoint — drives the dropdown.
  List<FavCategoryItemModel> dropdownCategories;
  // One-shot signal: set true when the last category empties out, telling the
  // screen to switch to organizer mode. Screen resets it after handling.
  bool switchToOrganizer;

  FavState(
    this.stateConstant,
    this.errorMessage,
    this.listOfFav,
    this.favSortOption,
    this.currentPage,
    this.hasNextPage,
    this.isPaginationLoading,
    this.limit,
    this.isCalendarOpen,
    this.selectedDate,
    this.calendarViewListOfFav,
    this.calendarViewStateConstant,
    this.favCategoryList,
    this.selectedFavCategory,
    this.calendarViewCurrentPage,
    this.calendarViewHasNextPage,
    this.calendarViewIsPaginationLoading,
    this.dateList,
    this.calendarViewErrorMessage,
    this.dropdownCategories,
    this.switchToOrganizer,
  );

  FavState copyWith({
    StateConstant? stateConstant,
    String? errorMessage,
    List<ListingModel>? listOfFav,
    FavSortOption? favSortOption,
    int? currentPage,
    bool? hasNextPage,
    bool? isPaginationLoading,
    int? limit,
    bool? isCalendarOpen,
    DateTime? selectedDate,
    List<ListingModel>? calendarViewListOfFav,
    StateConstant? calendarViewStateConstant,
    List<FavCategoryModel>? favCategoryList,
    String? selectedFavCategory,
    int? calendarViewCurrentPage,
    bool? calendarViewHasNextPage,
    bool? calendarViewIsPaginationLoading,
    List<String>? dateList,
    String? calendarViewErrorMessage,
    List<FavCategoryItemModel>? dropdownCategories,
    bool? switchToOrganizer,
  }) {
    return FavState(
      stateConstant ?? this.stateConstant,
      errorMessage ?? this.errorMessage,
      listOfFav ?? this.listOfFav,
      favSortOption ?? this.favSortOption,
      currentPage ?? this.currentPage,
      hasNextPage ?? this.hasNextPage,
      isPaginationLoading ?? this.isPaginationLoading,
      limit ?? this.limit,
      isCalendarOpen ?? this.isCalendarOpen,
      selectedDate ?? this.selectedDate,
      calendarViewListOfFav ?? this.calendarViewListOfFav,
      calendarViewStateConstant ?? this.calendarViewStateConstant,
      favCategoryList ?? this.favCategoryList,
      selectedFavCategory ?? this.selectedFavCategory,
      calendarViewCurrentPage ?? this.calendarViewCurrentPage,
      calendarViewHasNextPage ?? this.calendarViewHasNextPage,
      calendarViewIsPaginationLoading ?? this.calendarViewIsPaginationLoading,
      dateList ?? this.dateList,
      calendarViewErrorMessage ?? this.calendarViewErrorMessage,
      dropdownCategories ?? this.dropdownCategories,
      switchToOrganizer ?? this.switchToOrganizer,
    );
  }
}
