import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/fav/data/model/response_model/fav_category_model.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';

class FavCategoryState {
  final StateConstant stateConstant;
  final String errorMessage;
  final List<ListingModel> items;
  final List<FavCategoryModel> subCategories;
  final String selectedSubCategory;
  final int currentPage;
  final bool hasNextPage;
  final bool isPaginationLoading;

  const FavCategoryState({
    this.stateConstant = StateConstant.loading,
    this.errorMessage = '',
    this.items = const [],
    this.subCategories = const [],
    this.selectedSubCategory = '',
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isPaginationLoading = false,
  });

  FavCategoryState copyWith({
    StateConstant? stateConstant,
    String? errorMessage,
    List<ListingModel>? items,
    List<FavCategoryModel>? subCategories,
    String? selectedSubCategory,
    int? currentPage,
    bool? hasNextPage,
    bool? isPaginationLoading,
  }) {
    return FavCategoryState(
      stateConstant: stateConstant ?? this.stateConstant,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      subCategories: subCategories ?? this.subCategories,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
    );
  }
}
