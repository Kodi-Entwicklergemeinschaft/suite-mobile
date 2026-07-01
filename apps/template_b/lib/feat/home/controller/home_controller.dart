import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_b/feat/listing/controllers/listing_provider.dart';
import 'package:template_b/feat/home/domain/usecases/get_home_config_usecase.dart';
import 'package:template_b/feat/home/domain/usecases/get_localities_usecase.dart';
import 'package:template_b/feat/home/domain/usecases/toggle_locality_usecase.dart';
import 'package:template_b/feat/home/domain/usecases/get_company_profiles_usecase.dart';
import 'package:template_b/feat/home/data/models/home_config.dart';
import 'package:template_b/feat/home/data/models/get_localities_filter_model.dart';
import 'package:template_b/feat/home/state/home_state.dart';
import 'package:template_b/feat/profile/domain/usecases/get_faq_usecase.dart';

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  () => HomeNotifier(),
);

class HomeNotifier extends Notifier<HomeState> {
  late GetHomeConfigUseCase _getHomeConfigUseCase;
  late GetLocalitiesUseCase _getLocalitiesUseCase;
  late ToggleLocalityUseCase _toggleLocalityUseCase;
  late GetCompanyProfilesUseCase _getCompanyProfilesUseCase;
  late GetFAQUseCase _getFAQUseCase;

  @override
  HomeState build() {
    _getHomeConfigUseCase = ref.read(getHomeConfigUseCaseProvider);
    _getLocalitiesUseCase = ref.read(getLocalitiesUseCaseProvider);
    _toggleLocalityUseCase = ref.read(toggleLocalityUseCaseProvider);
    _getCompanyProfilesUseCase = ref.read(getCompanyProfilesUseCaseProvider);
    _getFAQUseCase = ref.read(getFAQUseCaseProvider);
    Future.microtask(() => _loadFAQ());
    return HomeState();
  }

  /// Load home configuration and localities.
  Future<void> loadConfig({bool preserveLocalitySelection = false}) async {
    // Step 1: Load home config
    final configResult = await _getHomeConfigUseCase(NoParams());

    await configResult.fold(
      (error) async {
        // Silently handle error
        dev.log('[HomeNotifier] Failed to load config: $error', error: error);
        state = state.copyWith(error: error.toString(), isSuccess: false);
      },
      (config) async {
        dev.log('[HomeNotifier] Config loaded, fetching localities...');

        // Step 2: Load localities if config has localities component.
        // If the user has scrolled past page 1, preserve the accumulated list in
        // all cases (toggle or pull-to-refresh) — only re-fetch when on page 1.
        if (config.localities != null) {
          if (state.localityPage > 1) {
            state = state.copyWith(config: config, isSuccess: true);
          } else {
            _loadLocalities(
              config,
              preserveSelectedIds: preserveLocalitySelection,
            );
          }
        } else {
          state = state.copyWith(config: config, isSuccess: true);
        }

        // Step 3: Load company profiles if feature_job_matching target exists in contentSlider
        if (config.contentSlider?.action?.target == 'feature_job_matching') {
          loadCompanyProfiles();
        }
      },
    );
  }

  static const int _localityPageSize = 10;

  Future<void> _loadLocalities(
    HomeConfigModel config, {
    bool preserveSelectedIds = false,
  }) async {
    final filter = GetLocalitiesFilterModel(page: 1, limit: _localityPageSize);
    final result = await _getLocalitiesUseCase(
      GetLocalitiesParams(filter: filter),
    );

    result.fold(
      (error) {
        dev.log(
          '[HomeNotifier] Failed to load localities: $error',
          error: error,
        );
        state = state.copyWith(
          config: config,
          localityItems: [],
          localityPage: 1,
          localityHasNextPage: false,
          isSuccess: true,
        );
      },
      (response) {
        dev.log(
          '[HomeNotifier] Loaded ${response.items.length} localities (total: ${response.meta.total})',
        );

        final selectedIds = preserveSelectedIds
            ? state.selectedLocalityIds
            : response.userSelectedLocalityIds.toSet();

        state = state.copyWith(
          config: config,
          localityItems: response.items,
          selectedLocalityIds: selectedIds,
          localityPage: 1,
          localityHasNextPage: response.meta.hasNextPage,
          isSuccess: true,
        );
      },
    );
  }

  Future<void> loadMoreLocalities() async {
    if (state.isLoadingMoreLocalities || !state.localityHasNextPage) return;

    state = state.copyWith(isLoadingMoreLocalities: true);
    final nextPage = state.localityPage + 1;

    final filter = GetLocalitiesFilterModel(
      page: nextPage,
      limit: _localityPageSize,
    );
    final result = await _getLocalitiesUseCase(
      GetLocalitiesParams(filter: filter),
    );

    result.fold(
      (error) {
        dev.log(
          '[HomeNotifier] Failed to load more localities: $error',
          error: error,
        );
        state = state.copyWith(isLoadingMoreLocalities: false);
      },
      (response) {
        dev.log(
          '[HomeNotifier] Loaded ${response.items.length} more localities (page $nextPage)',
        );

        final markedItems = response.items
            .map(
              (item) => LocalityItem(
                id: item.id,
                code: item.code,
                name: item.name,
                description: item.description,
                centerLat: item.centerLat,
                centerLng: item.centerLng,
                sortOrder: item.sortOrder,
                isActive: item.isActive,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                isSelected: state.selectedLocalityIds.contains(item.id),
                image: item.image,
              ),
            )
            .toList();

        state = state.copyWith(
          localityItems: [...state.localityItems, ...markedItems],
          localityPage: nextPage,
          localityHasNextPage: response.meta.hasNextPage,
          isLoadingMoreLocalities: false,
        );
      },
    );
  }

  /// Toggle locality selection by ID
  /// Returns true if selection was updated, false if max limit reached
  bool toggleLocalitySelection(String id) {
    final currentSelected = Set<String>.from(state.selectedLocalityIds);
    final maxSelection = state.config?.localities?.maxLocalities ?? 3;

    if (currentSelected.contains(id)) {
      // Deselect
      currentSelected.remove(id);
      state = state.copyWith(selectedLocalityIds: currentSelected);
      _toggleLocalitySelection(
        currentSelected.toList(),
      ).then((_) => _refreshAfterToggle());
      return true;
    } else {
      // Select only if under max limit
      if (currentSelected.length < maxSelection) {
        currentSelected.add(id);
        state = state.copyWith(selectedLocalityIds: currentSelected);
        _toggleLocalitySelection(
          currentSelected.toList(),
        ).then((_) => _refreshAfterToggle());
        return true;
      } else {
        // Max limit reached
        return false;
      }
    }
  }

  /// Set selected localities (for dropdown multi-select)
  void setSelectedLocalities(List<LocalityItem> items) {
    final maxSelection = state.config?.localities?.maxLocalities ?? 3;
    final ids = items.take(maxSelection).map((item) => item.id).toSet();
    state = state.copyWith(selectedLocalityIds: ids);

    // Call API then refresh — preserve in-memory selection to avoid star flicker
    _toggleLocalitySelection(ids.toList()).then((_) => _refreshAfterToggle());
  }

  /// Clear all selected localities
  void clearLocalitySelection() {
    state = state.copyWith(selectedLocalityIds: {});
  }

  /// Private method to sync selection with API
  Future<void> _toggleLocalitySelection(List<String> selectedIds) async {
    try {
      dev.log(
        '[HomeNotifier] Syncing locality selection with API: $selectedIds',
      );

      final params = ToggleLocalityParams(localityIds: selectedIds.toList());
      final result = await _toggleLocalityUseCase(params);

      result.fold(
        (error) {
          dev.log(
            '[HomeNotifier] Failed to sync selection: $error',
            error: error,
          );
          state = state.copyWith(error: error.toString());
        },
        (response) {
          dev.log('[HomeNotifier] Successfully synced selection');
          if (!(response.success ?? false)) {
            state = state.copyWith(
              error: response.message ?? 'Failed to update selection',
            );
          } else {
            state = state.copyWith(
              localityToggleVersion: state.localityToggleVersion + 1,
            );
          }
        },
      );
    } catch (e) {
      dev.log(
        '[HomeNotifier] Unexpected error syncing selection: $e',
        error: e,
      );
      state = state.copyWith(error: 'Failed to sync selection: $e');
    }
  }

  /// Refresh listing providers with correct categorySlug when locality selection changes
  void _invalidateListingProviders() {
    if (state.config?.contentSlider?.action?.target == 'category') {
      final category =
          state.config!.contentSlider!.action?.config?.category ?? '';
      if (category.isNotEmpty) {
        final sliderKey = '${category}_widget';
        ref
            .read(listingProviderFamily(sliderKey).notifier)
            .refresh(categorySlug: category);
        dev.log('[HomeNotifier] Refreshed listing provider: $sliderKey');
      }
    }
    if (state.config?.contentFeed?.action?.target == 'category') {
      final category =
          state.config!.contentFeed!.action?.config?.category ?? '';
      if (category.isNotEmpty) {
        final feedKey = '${category}_widget';
        ref
            .read(listingProviderFamily(feedKey).notifier)
            .refresh(categorySlug: category);
        dev.log('[HomeNotifier] Refreshed listing provider: $feedKey');
      }
    }
  }

  /// Load company profiles for company matching widget
  Future<void> loadCompanyProfiles({int page = 1, int limit = 10}) async {
    state = state.copyWith(
      isLoadingCompanyProfiles: true,
      companyProfilesError: null,
    );

    final params = GetCompanyProfilesParams(page: page, limit: limit);
    final result = await _getCompanyProfilesUseCase(params);

    result.fold(
      (error) {
        dev.log(
          '[HomeNotifier] Failed to load company profiles: $error',
          error: error,
        );
        state = state.copyWith(
          isLoadingCompanyProfiles: false,
          companyProfilesError: error.toString(),
        );
      },
      (companies) {
        dev.log('[HomeNotifier] Loaded ${companies.length} company profiles');
        state = state.copyWith(
          isLoadingCompanyProfiles: false,
          companyProfiles: companies,
        );
      },
    );
  }

  /// Load FAQ data
  Future<void> _loadFAQ() async {
    final result = await _getFAQUseCase.call(NoParams());
    result.fold(
      (error) {
        dev.log('[HomeNotifier] Failed to load FAQ: $error', error: error);
        // Don't update state on FAQ error, just log it
      },
      (faqData) {
        dev.log('[HomeNotifier] FAQ loaded successfully');
        state = state.copyWith(faqData: faqData);
      },
    );
  }

  Future<void> _refreshAfterToggle() async {
    dev.log('[HomeNotifier] Refreshing after toggle (preserving selection)...');
    await loadConfig(preserveLocalitySelection: true);
    _invalidateListingProviders();
  }

  Future<void> refresh({bool resetLocality = false}) async {
    dev.log('[HomeNotifier] Starting full refresh...');

    if (resetLocality) {
      state = state.copyWith(localityPage: 1);
    }

    // Step 1: Load config first (includes localities and company profiles if needed)
    await loadConfig();

    dev.log('[HomeNotifier] Config loaded, invalidating listing providers...');

    // Step 2: Invalidate all listing providers to refresh content
    _invalidateListingProviders();

    dev.log('[HomeNotifier] Full refresh completed');
  }
}
