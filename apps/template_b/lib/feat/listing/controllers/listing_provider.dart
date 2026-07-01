import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;
import 'package:template_b/feat/home/controller/home_controller.dart';
import '../data/models/listing_filter_model.dart';
import '../data/models/listing_model.dart';
import '../data/models/listing_filter_config_response_model.dart';
import '../domain/usecases/get_listings_usecase.dart';
import '../domain/usecases/get_listing_filter_config_usecase.dart';
import '../data/repositories/listing_repository_impl.dart';
import '../state/listing_state.dart';

// Mutable state provider for filter - family keyed by composite string "{categorySlug}_{context}"
final listingFilterProviderFamily = NotifierProvider.autoDispose.family<
    FilterNotifier,
    ListingFilterModel,
    String>((key) => FilterNotifier(key));

class FilterNotifier extends Notifier<ListingFilterModel> {
  FilterNotifier(this.key);
  final String key;

  @override
  ListingFilterModel build() {
    return ListingFilterModel();
  }

  void updateFilter(ListingFilterModel filter) {
    state = filter;
  }
}
/// Provider for listing list state - family keyed by composite string "{categorySlug}_{context}"
final listingProviderFamily = NotifierProvider.autoDispose.family<
    ListingNotifier,
    ListingState,
    String>((key) => ListingNotifier(key));

/// Notifier for listing list state management
/// Note: tenantId is passed automatically via HeaderInterceptor from preferences
class ListingNotifier extends Notifier<ListingState> {
  ListingNotifier(this.key);
  final String key;

  late GetListingsUseCase _getListingsUseCase;

  @override
  ListingState build() {
    _initializeUseCase();

    Future.microtask(() {
      if (ref.mounted) loadListings();
    });
    return ListingState(filter: ListingFilterModel());
  }

  void _initializeUseCase() {
    final repository = ref.read(listingRepositoryProvider);
    _getListingsUseCase = GetListingsUseCase(repository: repository);
  }

  /// Load listings based on current filter
  Future<void> loadListings() async {
    final filter = ref.read(listingFilterProviderFamily(key));
    state = state.copyWith(isLoading: true, error: null, filter: filter);

    try {
      final result = await _getListingsUseCase.call(filter);
      if (!ref.mounted) return;
      result.fold(
        (error) => state = state.copyWith(isLoading: false, error: error.toString()),
        (data) => state = state.copyWith(isLoading: false, data: data, currentPage: filter.page ?? 1),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// Update filter and reload listings
  Future<void> updateFilter(ListingFilterModel newFilter) async {
    ref
        .read(listingFilterProviderFamily(key).notifier)
        .updateFilter(newFilter.copyWith(page: 1));
    await loadListings();
  }

  /// Load next page
  Future<void> loadNextPage({String? categorySlug}) async {
    if (!state.hasNextPage || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    // Use state.filter as source of truth to preserve search query across pages
    final currentFilter = state.filter;
    var newFilter = currentFilter.copyWith(page: nextPage);
    if (categorySlug != null && categorySlug.isNotEmpty) {
      newFilter = newFilter.copyWith(categorySlug: categorySlug);
    }

    ref.read(listingFilterProviderFamily(key).notifier).updateFilter(newFilter);

    try {
      final result = await _getListingsUseCase.call(newFilter);
      if (!ref.mounted) return;
      result.fold(
        (error) {
          state = state.copyWith(isLoadingMore: false, error: error.toString());
        },
        (newData) {
          final combinedItems = <ListingModel>[
            ...(state.data?.items ?? []),
            ...(newData.items ?? []),
          ];
          final updatedData = newData.copyWith(items: combinedItems);
          state = state.copyWith(
            isLoadingMore: false,
            data: updatedData,
            currentPage: nextPage,
          );
        },
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }

  /// Search listings
  Future<void> search(String query, {String? categorySlug, bool? isSearch}) async {
    final currentFilter = ref.read(listingFilterProviderFamily(key));
    var newFilter = currentFilter.copyWith(search: query, page: 1, isSearch: isSearch);
    if (categorySlug != null && categorySlug.isNotEmpty) {
      newFilter = newFilter.copyWith(categorySlug: categorySlug);
    }
    await updateFilter(newFilter);
  }

  /// Clear filters and reload
  Future<void> clearFilters({String? categorySlug}) async {
    final slug = categorySlug ?? state.filter.categorySlug;
    final defaultFilter = ListingFilterModel(
      categorySlug: slug,
      isSearch: state.filter.isSearch,
    );
    await updateFilter(defaultFilter);
  }

  /// Refresh listings - reset to first page and reload
  Future<void> refresh({String? categorySlug}) async {
    // Use state.filter as source of truth to preserve search query on refresh
    final refreshFilter = state.filter.copyWith(page: 1);
    final finalFilter = categorySlug != null && categorySlug.isNotEmpty
        ? refreshFilter.copyWith(categorySlug: categorySlug)
        : refreshFilter;
    ref.read(listingFilterProviderFamily(key).notifier).updateFilter(finalFilter);
    await loadListings();
  }
}

/// Provider for filter config per category slug - family keyed by categorySlug
final listingFilterConfigProviderFamily = FutureProvider.family<
    FilterConfigData?,
    String>((ref, categorySlug) async {
  try {
    dev.log('[listingFilterConfigProvider] Fetching filter config for: $categorySlug');
    final useCase = ref.read(getListingFilterConfigUseCaseProvider);
    final params = GetListingFilterConfigParams(categorySlug: categorySlug);
    final result = await useCase(params);

    return result.fold(
      (error) {
        dev.log('[listingFilterConfigProvider] Failed to fetch: $error', error: error);
        return null;
      },
      (response) {
        dev.log('[listingFilterConfigProvider] Loaded successfully');
        return response.data;
      },
    );
  } catch (e, stackTrace) {
    dev.log('[listingFilterConfigProvider] Error: $e', error: e, stackTrace: stackTrace);
    return null;
  }
});
