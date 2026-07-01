import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/category/controller/category_screen_controller.dart';
import 'package:template_a/feat/category/data/models/category_filter_model.dart';
import 'package:template_a/feat/category/state/category_screen_state.dart';
import 'package:template_a/feat/fav/controller/fav_category_screen_controller.dart';
import 'package:template_a/feat/fav/controller/fav_controller.dart';
import 'package:template_a/feat/fav/state/fav_category_state.dart';
import 'package:template_a/feat/filter/controller/date_filter_controller.dart';
import 'package:template_a/feat/filter/controller/quick_filter_controller.dart';
import 'package:template_a/feat/filter/presentation/category_filter_bottom_sheet.dart';
import 'package:template_a/feat/filter/presentation/date_range_filter_bottom_sheet.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_a/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_a/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/fav/provider/active_fav_category_keys_provider.dart';
import 'package:template_a/feat/listing/provider/active_listing_screen_keys_provider.dart';
import 'package:template_a/feat/listing/state/listing_screen_state.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';
import 'package:template_a/core/utils/location_service.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/core/widgets/register_dialog.dart';

class CategoryScreenParams {
  final String categorySlug;
  final String screenTitle;
  // true for event-type categories → shows date range filter instead of attribute filter
  final bool isEventCategory;
  // pre-select a filter chip on open (V6 sub-category card tap)
  final String? preSelectedFilter;
  // true when navigating from the profile favourites section
  final bool fromFavorites;
  // header/accent colour passed from the fav categories API response
  final String? headerColorHex;
  final bool? showFilter;

  const CategoryScreenParams({
    required this.categorySlug,
    this.screenTitle = '',
    this.isEventCategory = false,
    this.preSelectedFilter,
    this.fromFavorites = false,
    this.headerColorHex,
    this.showFilter,
  });
}

class CategoryScreen extends BaseStatefulWidget {
  final CategoryScreenParams params;

  const CategoryScreen({super.key, required this.params});

  @override
  String? get screenName => params.categorySlug.isNotEmpty ? params.categorySlug : null;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends BaseStatefulWidgetState<CategoryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _preFilterApplied = false;
  late ActiveListingScreenKeysNotifier _activeKeysNotifier;
  late ActiveFavCategoryKeysNotifier _activeFavKeysNotifier;
  late dynamic _categoryNotifier;
  late dynamic _quickFilterNotifier;
  late dynamic _dateFilterNotifier;

  String get _listingFamilyKey => '${widget.params.categorySlug}_category';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChangedFavOnly);
    _scrollController.addListener(_onScroll);
    _activeKeysNotifier = ref.read(activeListingScreenKeysProvider.notifier);
    _activeFavKeysNotifier = ref.read(activeFavCategoryKeysProvider.notifier);
    final slug = widget.params.categorySlug;
    _categoryNotifier = ref.read(categoryScreenControllerProvider(slug).notifier);
    _quickFilterNotifier = ref.read(quickFilterControllerProvider(slug).notifier);
    _dateFilterNotifier = ref.read(dateFilterControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Register this screen's listing key so the broadcast service can reach it
      _activeKeysNotifier.add(_listingFamilyKey);
      if (widget.params.fromFavorites) {
        _activeFavKeysNotifier.add(widget.params.categorySlug);
        ref
            .read(favCategoryScreenProvider(widget.params.categorySlug).notifier)
            .load();
      } else {
        ref.read(dateFilterControllerProvider.notifier).reset();
        _loadCategoryAndApplyPreFilter();
      }
    });
  }

  Future<void> _loadCategoryAndApplyPreFilter() async {
    final preFilter = widget.params.preSelectedFilter;
    final slug = widget.params.categorySlug;
    final notifier = ref.read(categoryScreenControllerProvider(slug).notifier);

    // If category data already loaded (e.g. by V6), skip reload
    final existingState = ref.read(categoryScreenControllerProvider(slug));
    if (existingState.category == null) {
      await notifier.loadCategory();
    }

    if (!mounted) return;

    if (preFilter != null && preFilter.isNotEmpty) {
      _preFilterApplied = true;
      notifier.selectFilter(preFilter);
      if (preFilter == '__nearby__') {
        _reloadListings(forceRadiusMeters: 1500);
      } else if (preFilter == '__see_all__') {
        _reloadListings();
      } else {
        _reloadListings(selectedFilter: preFilter);
      }
    } else {
      notifier.clearFilter();
      _reloadListings();
    }
  }

  void _onSearchChangedFavOnly() {
    if (!widget.params.fromFavorites) return;
    final query = _searchController.text.trim();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text.trim() == query && query != _searchQuery) {
        setState(() => _searchQuery = query);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      if (widget.params.fromFavorites) {
        ref
            .read(favCategoryScreenProvider(widget.params.categorySlug).notifier)
            .loadMore();
      } else {
        ref
            .read(listingScreenControllerProvider(_listingFamilyKey).notifier)
            .loadMore();
      }
    }
  }

  Future<void> _reloadListings({
    String? selectedFilter,
    String? search,
    List<String>? groupFilterIds,
    DateTime? startDate,
    DateTime? endDate,
    String? overrideCategorySlug,
    int? forceRadiusMeters,
  }) async {
    int? radius;
    bool isQuickFilterSelected = false;

    if (forceRadiusMeters != null) {
      radius = forceRadiusMeters;
    } else if (selectedFilter != null) {
      final children = ref
              .read(categoryScreenControllerProvider(widget.params.categorySlug))
              .category
              ?.quickFilters ??
          [];
      final match = children.where((f) => f.slug == selectedFilter).firstOrNull;
      radius = match?.radiusMeters;
      isQuickFilterSelected = match?.isQuickFilter ?? false;
    }

    final parentSlug = overrideCategorySlug ?? widget.params.categorySlug;

    // subcategorySlug: selected child filter, or fall back to parent slug
    final subcategorySlug = (selectedFilter != null && !isQuickFilterSelected)
        ? selectedFilter
        : parentSlug;

    double? latitude;
    double? longitude;
    final position = await LocationService().getCurrentLocation();
    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;
    }

    if (!mounted) return;

    final filter = ListingFilterModel(
      subcategorySlug: subcategorySlug,
      search: search?.isEmpty == true ? null : search,
      radiusMeters: radius,
      latitude: latitude,
      longitude: longitude,
      limit: 20,
      page: 1,
      groupFilterIds: groupFilterIds,
      eventStartFrom: startDate?.toIso8601String(),
      eventStartTo: endDate?.toIso8601String(),
      eventSort: true,
    );

    ref
        .read(listingScreenControllerProvider(_listingFamilyKey).notifier)
        .getListing(filter);
  }

  @override
  void dispose() {
    final key = _listingFamilyKey;
    final fromFav = widget.params.fromFavorites;
    final slug = widget.params.categorySlug;
    Future.microtask(() {
      _activeKeysNotifier.remove(key);
      if (fromFav) _activeFavKeysNotifier.remove(slug);
      _categoryNotifier.clearFilter();
      _quickFilterNotifier.resetFilters();
      _dateFilterNotifier.reset();
    });
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChangedFavOnly);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.params.fromFavorites) {
      final favState = ref.watch(
        favCategoryScreenProvider(widget.params.categorySlug),
      );
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(showFilter: widget.params.showFilter != false),
              Expanded(child: _buildFavListingBody(favState)),
            ],
          ),
        ),
      );
    }

    final categoryState = ref.watch(
      categoryScreenControllerProvider(widget.params.categorySlug),
    );
    final listingState = ref.watch(
      listingScreenControllerProvider(_listingFamilyKey),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(showFilter: widget.params.showFilter != false),
            SizedBox(height: 8.h),
            if (categoryState.stateConstant == StateConstant.loading)
              _buildFilterChipsShimmer(
                widget.params.headerColorHex != null && widget.params.headerColorHex!.isNotEmpty
                    ? _parseTitleColor(widget.params.headerColorHex)
                    : null,
              )
            else if (categoryState.stateConstant == StateConstant.success &&
                (categoryState.category?.quickFilters.isNotEmpty ?? false))
              _buildFilterChips(categoryState),
            Expanded(child: _buildListingBody(listingState, categoryState)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar({bool showFilter = true}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? TemplateAColors.lightModeBackground
        : theme.colorScheme.primary;
    final hintColor = isDark
        ? TemplateAColors.darkModeBackground.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.85);
    final iconColor = isDark ? TemplateAColors.darkModeBackground : Colors.white;
    final hintFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;

    Color? headerColor;
    if (showFilter) {
      headerColor = widget.params.fromFavorites
          ? _parseTitleColor(widget.params.headerColorHex)
          : _parseTitleColor(
              ref
                  .watch(categoryScreenControllerProvider(widget.params.categorySlug))
                  .category
                  ?.titleBackgroundColor,
            );
    }

    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: showFilter ? 5.w : 16.w, top: 5.h, bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (context.canPop())
            Semantics(
              button: true,
              label: 'back_button_label'.tr,
              child: SizedBox(
                width: 36,
                height: 48,
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Center(
                    child: ExcludeSemantics(
                      child: CommonIcon(
                        icon: Icons.arrow_back_ios,
                        size: 22,
                        label: 'back_button_label'.tr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: SearchBarWidget(
              controller: _searchController,
              borderRadius: 12,
              filled: true,
              showBorder: false,
              focusColor: Colors.white,
              fillColor: fillColor,
              minHeight: 48,
              maxHeight: 48,
              hintFontSize: hintFontSize,
              hintTextColor: hintColor,
              textColor: isDark ? TemplateAColors.darkModeBackground : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              onDone: () {
                final query = _searchController.text.trim();
                _searchQuery = query;
                final slug = widget.params.categorySlug;
                final selectedFilter =
                    ref.read(categoryScreenControllerProvider(slug)).selectedFilterSlug;
                final activeFilterIds = ref
                    .read(quickFilterControllerProvider(slug))
                    .selectedFilterIds;
                final dateState = ref.read(dateFilterControllerProvider);
                _reloadListings(
                  selectedFilter: selectedFilter,
                  search: query.isEmpty ? null : query,
                  groupFilterIds: activeFilterIds.isEmpty ? null : activeFilterIds,
                  startDate: dateState.startDate,
                  endDate: dateState.endDate,
                );
              },
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: CommonIcon(
                  icon: Icons.search,
                  size: 22,
                  color: iconColor,
                  label: 'search'.tr,
                ),
              ),
            ),
          ),
          if (showFilter) ...[
            const SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Semantics(
                button: true,
                label: 'filter'.tr,
                child: GestureDetector(
                  onTap: () => _onFilterTap(headerColor!),
                  child: ExcludeSemantics(
                    child: _buildFilterIconWithIndicator(headerColor),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterIconWithIndicator(Color? headerColor) {
    final slug = widget.params.categorySlug;
    final hasGroupFilter = ref
        .watch(quickFilterControllerProvider(slug))
        .selectedFilterIds
        .isNotEmpty;
    final hasDateFilter = ref.watch(dateFilterControllerProvider).hasActiveFilters;
    final isActive = hasGroupFilter || hasDateFilter;
    final activeColor = headerColor ?? Theme.of(context).colorScheme.secondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        CommonImage(
          imagePath: Images.filterIcon,
          width: 36,
          height: 36,
          label: 'filter_icon_label'.tr,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: activeColor, width: 2.5)
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _onFilterTap(Color headerColor) async {
    final slug = widget.params.categorySlug;

    if (widget.params.fromFavorites) {
      final isEvent = slug.contains('event');
      if (isEvent) {
        final result = await showDateRangeFilterBottomSheet(context: context);
        if (result != null && mounted) {
          ref.read(favScreenControllerProvider.notifier).getFavListing(
            category: slug,
            startDate: result['start'],
            endDate: result['end'],
          );
        }
      } else {
        final result = await showCategoryFilterBottomSheet(
          context: context,
          categorySlug: slug,
        );
        if (result != null && mounted) {
          ref.read(favScreenControllerProvider.notifier).getFavListing(category: slug);
        }
      }
      return;
    }

    if (widget.params.isEventCategory) {
      // Date range filter for event categories
      final result = await showDateRangeFilterBottomSheet(context: context);
      if (result != null && mounted) {
        final dateState = ref.read(dateFilterControllerProvider);
        _reloadListings(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          selectedFilter: ref
              .read(categoryScreenControllerProvider(slug))
              .selectedFilterSlug,
          startDate: dateState.startDate,
          endDate: dateState.endDate,
        );
      }
    } else {
      // Attribute filter for all other categories
      final result = await showCategoryFilterBottomSheet(
        context: context,
        categorySlug: slug,
      );
      if (result != null && mounted) {
        _reloadListings(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          selectedFilter: ref
              .read(categoryScreenControllerProvider(slug))
              .selectedFilterSlug,
          groupFilterIds: result.isEmpty ? null : result,
        );
      }
    }
  }

  Color _parseTitleColor(String? hex) {
    if (hex == null || hex.isEmpty) return Theme.of(context).colorScheme.secondary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget _buildFilterChipsShimmer(Color? categoryColor) {
    return SizedBox(
      height: 160.h,
      child: ShimmerWidget(
        baseColor: categoryColor?.withValues(alpha: 0.7),
        highlightColor: categoryColor != null ? const Color(0x80FFFFFF) : null,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 5,
          itemBuilder: (_, __) => Container(
            width: 120.w,
            height: 160.h,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(CategoryScreenState state) {
    final allEnabled = (state.category?.children ?? <CategoryChild>[])
        .where((c) => c.enabled)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final hasQuickFilters = allEnabled.any((c) => c.isQuickFilter);
    // no quickFilters from BE → inject static Nearby (first) + See All (last)
    final staticNearby = CategoryChild(
      id: '__nearby__',
      slug: '__nearby__',
      title: 'nearby'.tr,
      image: 'assets/images/nearby.webp',
      isQuickFilter: false,
      order: -1,
    );
    final staticSeeAll = CategoryChild(
      id: '__see_all__',
      slug: '__see_all__',
      title: 'see_all'.tr,
      image: 'assets/images/see_all.webp',
      isQuickFilter: false,
      order: 9999,
    );
    final children = hasQuickFilters
        ? allEnabled
        : [staticNearby, ...allEnabled, staticSeeAll];

    final selectedSlug = state.selectedFilterSlug;
    final titleColor = _parseTitleColor(state.category?.titleBackgroundColor);

    return SizedBox(
      height: 140.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isStatic = child.id == '__nearby__' || child.id == '__see_all__';
          return CommonImageTextCard(
            title: child.title,
            imageUrl: child.image ?? '',
            titleColor: titleColor,
            isSelected: child.slug == selectedSlug,
            onTap: () {
              final isAlreadySelected = child.slug == selectedSlug;
              final controller = ref.read(
                categoryScreenControllerProvider(widget.params.categorySlug).notifier,
              );
              if (isAlreadySelected) {
                controller.clearFilter();
              } else {
                controller.selectFilter(child.slug);
              }
              final activeFilterIds = ref
                  .read(quickFilterControllerProvider(widget.params.categorySlug))
                  .selectedFilterIds;
              final dateState = ref.read(dateFilterControllerProvider);
              _reloadListings(
                search: _searchQuery.isEmpty ? null : _searchQuery,
                groupFilterIds: activeFilterIds.isEmpty ? null : activeFilterIds,
                startDate: dateState.startDate,
                endDate: dateState.endDate,
                selectedFilter: isAlreadySelected ? null : (isStatic ? null : child.slug),
                forceRadiusMeters: (!isAlreadySelected && child.id == '__nearby__') ? 1500 : null,
              );
            },
          );
        },
      ),
    );
  }

  List<ListingModel> _applyFavSearch(List<ListingModel> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items
        .where((i) =>
            (i.title?.toLowerCase().contains(q) ?? false) ||
            (i.address?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Widget _buildFavListingBody(FavCategoryState favState) {
    final headerColor = _parseTitleColor(widget.params.headerColorHex);

    if (favState.stateConstant == StateConstant.loading && favState.items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: headerColor));
    }

    if (favState.stateConstant == StateConstant.error && favState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText(
              titleText: favState.errorMessage,
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => ref
                  .read(favCategoryScreenProvider(widget.params.categorySlug).notifier)
                  .load(),
              child: Text('retryButton'.tr),
            ),
          ],
        ),
      );
    }

    final visibleItems = _applyFavSearch(favState.items);

    if (visibleItems.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'no_fav_listing'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(favCategoryScreenProvider(widget.params.categorySlug).notifier)
          .load(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 0),
            sliver: SliverList.builder(
              itemCount:
                  visibleItems.length + (favState.isPaginationLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == visibleItems.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: CircularProgressIndicator(color: headerColor),
                    ),
                  );
                }
                final item = visibleItems[index];
                return ListingCard(
                  imageUrl: item.firstImageUrl,
                  name: item.title ?? '',
                  address: item.address,
                  todayOpeningStatus: _getDateRange(item),
                  headerColor: headerColor,
                  imageLabel: 'listing_image_label'.tr,
                  isFavourite: item.isFavourite,
                  distance: item.distance,
                  searchedString: _searchQuery.isEmpty ? null : _searchQuery,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: item, searchedText: _searchQuery.isEmpty ? null : _searchQuery, categorySlug: widget.params.categorySlug),
                    ),
                  ),
                  onTapFavourite: () => ref
                      .read(favCategoryScreenProvider(widget.params.categorySlug).notifier)
                      .removeFav(item.id ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingBody(ListingScreenState listingState, CategoryScreenState categoryState) {
    final headerColor = _parseTitleColor(categoryState.category?.titleBackgroundColor);

    if (categoryState.stateConstant == StateConstant.loading ||
        (listingState.stateConstant == StateConstant.loading &&
            listingState.items.isEmpty)) {
      return Center(
        child: CircularProgressIndicator(color: headerColor),
      );
    }

    if (listingState.stateConstant == StateConstant.error &&
        listingState.items.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'error_loading'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    if (listingState.items.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'no_listings'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(listingScreenControllerProvider(_listingFamilyKey).notifier)
          .refresh(),
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 0),
            sliver: SliverList.builder(
              itemCount: listingState.items.length + (listingState.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == listingState.items.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: CircularProgressIndicator(color: headerColor),
                    ),
                  );
                }
                final item = listingState.items[index];
                return ListingCard(
                  imageUrl: item.firstImageUrl,
                  name: item.title ?? '',
                  address: item.address,
                  todayOpeningStatus: _getDateRange(item),
                  headerColor: headerColor,
                  imageLabel: 'listing_image_label'.tr,
                  isFavourite: item.isFavourite,
                  distance: item.distance,
                  searchedString: _searchQuery.isEmpty ? null : _searchQuery,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: item, searchedText: _searchQuery.isEmpty ? null : _searchQuery, categorySlug: widget.params.categorySlug),
                      ),
                    );
                  },
                  onTapFavourite: () => _onFavTap(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onFavTap(BuildContext context, ListingModel item) {
    final id = item.id ?? '';
    if (id.isEmpty) return;
    final prefs = ref.read(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;

    if (!isFullyLoggedIn) {
      showRegisterDialog(context, ref);
    } else {
      ref.read(favouriteToggleServiceProvider).toggleFav(
            id: id,
            newValue: !item.isFavourite,
          );
    }
  }

  String? _getDateRange(ListingModel item) {
    // eventStart → show date (events)
    // timeIntervals only → show open/closed (shops/POI)
    if (item.eventStart != null && item.eventStart!.isNotEmpty) {
      // fall through to date display below
    } else if (item.timeIntervals != null && item.timeIntervals!.isNotEmpty) {
      return _getTodayOpeningHoursFromIntervals(item.timeIntervals!);
    }
    if (item.eventStart == null) return null;
    try {
      final s = DateTime.parse(item.eventStart!).toLocal();
      final startDate =
          '${s.day.toString().padLeft(2, '0')}.${s.month.toString().padLeft(2, '0')}.${s.year}';
      final startTime =
          '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
      if (item.eventEnd == null || item.eventEnd!.isEmpty) {
        return '$startDate · $startTime';
      }
      final e = DateTime.parse(item.eventEnd!).toLocal();
      final endTime =
          '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}';
      final sameDay =
          s.year == e.year && s.month == e.month && s.day == e.day;
      if (sameDay) return '$startDate · $startTime – $endTime';
      final endDate =
          '${e.day.toString().padLeft(2, '0')}.${e.month.toString().padLeft(2, '0')}.${e.year}';
      return '$startDate · $startTime ${'to'.tr} $endDate · $endTime';
    } catch (_) {
      return null;
    }
  }

  String _getTodayOpeningHoursFromIntervals(List<dynamic> intervals) {
    final now = DateTime.now();
    final todayWeekday = DateFormat('EEEE', 'en_US').format(now);
    for (final interval in intervals) {
      if (interval.start == null || interval.end == null) continue;
      if (interval.weekdays?.any((d) => d.toUpperCase() == todayWeekday.toUpperCase()) ?? false) {
        final start = DateTime.parse(interval.start!).toUtc();
        final end = DateTime.parse(interval.end!).toUtc();
        return '${'open_hours'.tr}'
            .replaceAll('{start}', DateFormat('HH:mm').format(start))
            .replaceAll('{end}', DateFormat('HH:mm').format(end));
      }
    }
    return 'closed'.tr;
  }
}

