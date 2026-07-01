import 'package:flutter/material.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/search/constant/search_sort_option.dart';

class SearchState {
  StateConstant stateConstant;
  String errorMessage;
  List<ListingModel> items;
  String searchQuery;
  DateTimeRange? dateFilter;
  bool isLocationFilterActive;
  bool isFreeEntryFilterActive;
  List<String> selectedCategorySlugs;
  SearchSortOption sortOption;
  int currentPage;
  bool hasNextPage;
  bool isPaginationLoading;
  int limit;
  int? totalCount;
  List<String> recentQueries;
  // Search-only location filter — does NOT affect global prefs
  double? filterLat;
  double? filterLon;
  double? filterRadiusKm;
  String? filterLocationName;

  SearchState(
    this.stateConstant,
    this.errorMessage,
    this.items,
    this.searchQuery,
    this.dateFilter,
    this.isLocationFilterActive,
    this.isFreeEntryFilterActive,
    this.selectedCategorySlugs,
    this.sortOption,
    this.currentPage,
    this.hasNextPage,
    this.isPaginationLoading,
    this.limit, [
    this.totalCount,
    this.recentQueries = const [],
    this.filterLat,
    this.filterLon,
    this.filterRadiusKm,
    this.filterLocationName,
  ]);

  SearchState copyWith({
    StateConstant? stateConstant,
    String? errorMessage,
    List<ListingModel>? items,
    String? searchQuery,
    DateTimeRange? dateFilter,
    bool? isLocationFilterActive,
    bool? isFreeEntryFilterActive,
    List<String>? selectedCategorySlugs,
    SearchSortOption? sortOption,
    int? currentPage,
    bool? hasNextPage,
    bool? isPaginationLoading,
    int? limit,
    int? totalCount,
    List<String>? recentQueries,
    double? filterLat,
    double? filterLon,
    double? filterRadiusKm,
    String? filterLocationName,
    bool clearDateFilter = false,
    bool clearLocationFilter = false,
  }) {
    return SearchState(
      stateConstant ?? this.stateConstant,
      errorMessage ?? this.errorMessage,
      items ?? this.items,
      searchQuery ?? this.searchQuery,
      clearDateFilter ? null : (dateFilter ?? this.dateFilter),
      isLocationFilterActive ?? this.isLocationFilterActive,
      isFreeEntryFilterActive ?? this.isFreeEntryFilterActive,
      selectedCategorySlugs ?? this.selectedCategorySlugs,
      sortOption ?? this.sortOption,
      currentPage ?? this.currentPage,
      hasNextPage ?? this.hasNextPage,
      isPaginationLoading ?? this.isPaginationLoading,
      limit ?? this.limit,
      totalCount ?? this.totalCount,
      recentQueries ?? this.recentQueries,
      clearLocationFilter ? null : (filterLat ?? this.filterLat),
      clearLocationFilter ? null : (filterLon ?? this.filterLon),
      clearLocationFilter ? null : (filterRadiusKm ?? this.filterRadiusKm),
      clearLocationFilter
          ? null
          : (filterLocationName ?? this.filterLocationName),
    );
  }
}
