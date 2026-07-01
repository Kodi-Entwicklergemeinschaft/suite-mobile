import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/enums/sort_by.dart';
import 'package:template_c/feat/listing/data/models/enums/sort_order.dart';
import 'package:template_c/feat/listing/domain/usecases/get_listings_usecase.dart';
import 'package:template_c/feat/search/constant/search_sort_option.dart';
import 'package:template_c/feat/search/filter/search_filter_controller.dart';
import 'package:template_c/feat/search/state/search_state.dart';

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(() => SearchController());

class SearchController extends Notifier<SearchState> {
  static const int _maxRecentQueries = 10;

  GetListingsUseCase get _useCase => ref.read(getListingUseCaseProvider);
  AppPreferenceManager get _preferences => ref.read(preferenceManagerProvider);

  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(
      () => ref.read(searchFilterControllerProvider.notifier).loadInterests(),
    );
    Future.microtask(_loadRecentQueries);
    return SearchState(
      StateConstant.loading,
      '',
      [],
      '',
      null,
      false,
      false,
      [],
      SearchSortOption.oldestFirst,
      1,
      false,
      false,
      20,
    );
  }

  Future<void> search() async {
    await _fetchPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (state.isPaginationLoading || !state.hasNextPage) return;
    await _fetchPage(state.currentPage + 1, replace: false);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      search();
    });
  }

  Future<void> submitSearchQuery(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    state = state.copyWith(searchQuery: query);
    await _saveRecentQueries(_updatedRecentQueries(query));
    _debounce?.cancel();
    await search();
  }

  Future<void> selectRecentQuery(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    state = state.copyWith(searchQuery: trimmedQuery);
    await _saveRecentQueries(_updatedRecentQueries(trimmedQuery));
    _debounce?.cancel();
    await search();
  }

  Future<void> persistCurrentQueryIfEligible() async {
    final query = state.searchQuery.trim();
    if (query.isEmpty || state.items.isEmpty) return;
    await _saveRecentQueries(_updatedRecentQueries(query));
  }

  Future<void> removeRecentQuery(String query) async {
    final updatedQueries = state.recentQueries
        .where((item) => item != query)
        .toList(growable: false);
    await _saveRecentQueries(updatedQueries);
  }

  Future<void> clearRecentQueries() async {
    await _preferences.removePreference(StorageKeys.recentSearchQueries);
    state = state.copyWith(recentQueries: const []);
  }

  Future<void> updateDateFilter(DateTimeRange? range) async {
    if (range == null) {
      state = state.copyWith(clearDateFilter: true);
    } else {
      state = state.copyWith(dateFilter: range);
    }
    await search();
  }

  Future<void> activateLocationFilter({
    required double lat,
    required double lon,
    required double radiusKm,
    required String locationName,
  }) async {
    state = state.copyWith(
      isLocationFilterActive: true,
      filterLat: lat,
      filterLon: lon,
      filterRadiusKm: radiusKm,
      filterLocationName: locationName,
    );
    await search();
  }

  Future<void> clearLocationFilter() async {
    state = state.copyWith(
      isLocationFilterActive: false,
      clearLocationFilter: true,
    );
    await search();
  }

  void toggleLocationFilter() {
    state = state.copyWith(
      isLocationFilterActive: !state.isLocationFilterActive,
    );
  }

  void toggleFreeEntry() {
    state = state.copyWith(
      isFreeEntryFilterActive: !state.isFreeEntryFilterActive,
    );
  }

  Future<void> updateSortOption(SearchSortOption option) async {
    state = state.copyWith(sortOption: option);
    await search();
  }

  Future<void> updateCategoryFilter(List<String> slugs) async {
    state = state.copyWith(selectedCategorySlugs: slugs);
    await search();
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    final pref = ref.read(preferenceManagerProvider);

    log(
      "---------------------------- Search Screen Listing ----------------------",
    );

    final dateFrom = state.dateFilter?.start;
    final dateTo = state.dateFilter?.end;

    final filter = ListingFilterModel(
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      subcategorySlugs: state.selectedCategorySlugs.isNotEmpty
          ? state.selectedCategorySlugs
          : null,
      eventStartFrom: dateFrom,
      eventStartTo: dateTo,
      page: page,
      limit: state.limit,
      sortBy: _getSortBy(),
      sortOrder: _getSortOrder(),
      latitude: state.isLocationFilterActive && state.filterLat != null
          ? state.filterLat
          : pref.getDouble(StorageKeys.lat),
      longitude: state.isLocationFilterActive && state.filterLon != null
          ? state.filterLon
          : pref.getDouble(StorageKeys.long),
      radiusMeters: state.isLocationFilterActive && state.filterRadiusKm != null
          ? (state.filterRadiusKm! * 1000).toInt()
          : (pref.getDouble(StorageKeys.radius) * 1000).toInt(),
      isInterested: false,
    );

    log(
      'fetchPage\n'
      '  page      : ${filter.page}\n'
      '  search    : ${filter.search}\n'
      '  sortBy    : ${filter.sortBy}\n'
      '  eventFrom : ${filter.eventStartFrom}\n'
      '  eventTo   : ${filter.eventStartTo}',
      name: 'SearchController',
    );

    if (replace) {
      state = state.copyWith(
        stateConstant: StateConstant.loading,
        items: [],
        currentPage: 0,
        isPaginationLoading: false,
      );
    } else {
      state = state.copyWith(isPaginationLoading: true);
    }

    try {
      final result = await _useCase.call(filter);

      result.fold(
        (error) {
          log('error p$page: $error', name: 'SearchController');
          state = state.copyWith(
            stateConstant: StateConstant.error,
            errorMessage: error.toString(),
            isPaginationLoading: false,
          );
        },
        (response) {
          final newItems = response.items ?? [];
          final merged = replace ? newItems : [...state.items, ...newItems];
          final hasMore = response.meta?.hasNextPage ?? newItems.isNotEmpty;

          state = state.copyWith(
            stateConstant: StateConstant.success,
            items: merged,
            currentPage: page,
            hasNextPage: hasMore,
            isPaginationLoading: false,
            totalCount: replace ? response.total : state.totalCount,
          );
        },
      );
    } catch (e) {
      log('exception p$page: $e', name: 'SearchController');
      state = state.copyWith(
        stateConstant: StateConstant.error,
        errorMessage: e.toString(),
        isPaginationLoading: false,
      );
    }
  }

  SortBy _getSortBy() {
    switch (state.sortOption) {
      case SearchSortOption.oldestFirst || SearchSortOption.newestFirst:
        return SortBy.eventStart;
      case SearchSortOption.alphabetical:
        return SortBy.title;
    }
  }

  SortOrder _getSortOrder() {
    switch (state.sortOption) {
      case SearchSortOption.oldestFirst || SearchSortOption.alphabetical:
        return SortOrder.asc;
      case SearchSortOption.newestFirst:
        return SortOrder.desc;
    }
  }

  Future<void> _loadRecentQueries() async {
    final rawValue = _preferences.getStringOrNull(
      StorageKeys.recentSearchQueries,
    );
    if (rawValue == null || rawValue.isEmpty) {
      state = state.copyWith(recentQueries: const []);
      return;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        state = state.copyWith(recentQueries: const []);
        return;
      }

      final uniqueQueries = <String>{};
      final recentQueries = decoded
          .whereType<String>()
          .map((query) => query.trim())
          .where((query) => query.isNotEmpty)
          .where(uniqueQueries.add)
          .take(_maxRecentQueries)
          .toList(growable: false);
      state = state.copyWith(recentQueries: recentQueries);
    } catch (_) {
      state = state.copyWith(recentQueries: const []);
    }
  }

  List<String> _updatedRecentQueries(String query) {
    return [
      query,
      ...state.recentQueries.where((item) => item != query),
    ].take(_maxRecentQueries).toList(growable: false);
  }

  Future<void> _saveRecentQueries(List<String> queries) async {
    state = state.copyWith(recentQueries: queries);
    if (queries.isEmpty) {
      await _preferences.removePreference(StorageKeys.recentSearchQueries);
      return;
    }

    await _preferences.saveString(
      StorageKeys.recentSearchQueries,
      jsonEncode(queries),
    );
  }
}
