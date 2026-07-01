import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/listing_filter_model.dart';
import '../../controllers/listing_provider.dart';
import '../widgets/listing_item_widget.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_detail_screen.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';

import 'dart:developer' as dev;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ListingScreenParams {
  final String categorySlug;
  final bool isSearch;
  final String? title;
  final bool showBackButton;
  final bool isBottomBar;

  ListingScreenParams({
    this.categorySlug = '',
    this.isSearch = false,
    this.title,
    this.showBackButton = true,
    this.isBottomBar = false,
  });

  factory ListingScreenParams.fromRawConfig(Map<String, dynamic>? rawConfig) {
    return ListingScreenParams(
      categorySlug:
          (rawConfig?['categorySlug'] as String?) ??
          (rawConfig?['category'] as String?) ??
          '',
      isSearch: rawConfig?['isSearch'] as bool? ?? false,
      title: rawConfig?['title'] as String?,
      isBottomBar: rawConfig?['isBottomBar'] as bool? ?? false,
    );
  }
}

/// Full screen listing with search, filter, and infinite scroll pagination
class ListingScreen extends BaseStatefulWidget {
  final ListingScreenParams? params;

  const ListingScreen({super.key, this.params});

  @override
  String get screenName => AppRouteConstants.featureListing.name;

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends BaseStatefulWidgetState<ListingScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late String _familyKey;
  late bool _isSearch;
  Future<void>? _searchDebounce;
  String _lastSearchQuery = ''; // Track last search to prevent duplicate calls

  @override
  void initState() {
    super.initState();
    _isSearch = widget.params?.isSearch ?? false;
    final isBottomBar = widget.params?.isBottomBar ?? false;
    _familyKey = _isSearch
        ? 'search_screen'
        : isBottomBar
        ? 'bottom_${widget.params?.categorySlug}_screen'
        : '${widget.params?.categorySlug}_screen';
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode = FocusNode();

    // Initialize filter with categorySlug if not in search mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isSearch) {
        ref
            .read(listingFilterProviderFamily(_familyKey).notifier)
            .updateFilter(ListingFilterModel(isSearch: true));
        _searchFocusNode.requestFocus();
      } else {
        final slug = widget.params?.categorySlug ?? '';
        if (slug.isNotEmpty) {
          ref
              .read(listingFilterProviderFamily(_familyKey).notifier)
              .updateFilter(ListingFilterModel(categorySlug: slug));
        }
      }
    });
  }

  /// Handle search input with debounce (500ms delay)
  /// Only searches with 3+ characters minimum
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel any pending search
    _searchDebounce?.ignore();

    // If less than 3 characters
    if (query.length < 3) {
      // Only reset if query was not empty before (to prevent duplicate calls)
      if (query.isEmpty && _lastSearchQuery.isNotEmpty && mounted) {
        _lastSearchQuery = '';
        ref
            .read(listingProviderFamily(_familyKey).notifier)
            .clearFilters(
              categorySlug: _isSearch ? null : widget.params?.categorySlug,
            );
      } else if (query.isEmpty) {
        _lastSearchQuery = '';
      }
      return;
    }

    // Debounce search for 3+ characters (wait 500ms after user stops typing)
    _searchDebounce = Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _lastSearchQuery != query) {
        _lastSearchQuery = query;
        ref
            .read(listingProviderFamily(_familyKey).notifier)
            .search(
              query,
              categorySlug: _isSearch ? null : widget.params?.categorySlug,
              isSearch: _isSearch ? true : null,
            );
      }
    });
  }

  /// Internal handler for listing item tap
  /// Navigates to detail screen with listing ID
  void _handleListingTap(ListingModel listing) {
    context.pushNamed(
      AppRouteConstants.featureListingDetail.name,
      extra: ListingDetailScreenParams(listingId: listing.id ?? ''),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.ignore();
    super.dispose();
  }

  void _onScroll() {
    // Check if user scrolled to bottom (trigger at 80% of scroll)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Only load more if not already loading and there are more pages
      final state = ref.read(listingProviderFamily(_familyKey));
      if (!state.isLoadingMore && state.hasNextPage) {
        ref
            .read(listingProviderFamily(_familyKey).notifier)
            .loadNextPage(
              categorySlug: _isSearch ? null : widget.params?.categorySlug,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);
        final listingState = ref.watch(listingProviderFamily(_familyKey));

        ref.listen(homeProvider.select((s) => s.localityToggleVersion), (
          previous,
          next,
        ) {
          dev.log(
            '[ListingScreen] locality toggle API succeeded — key: $_familyKey | version: $previous → $next',
          );
          ref
              .read(listingProviderFamily(_familyKey).notifier)
              .refresh(
                categorySlug: _isSearch ? null : widget.params?.categorySlug,
              );
        });

        return _buildScaffold(context, ref, theme, listingState);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    dynamic listingState,
  ) {
    // Use custom title from params if provided, otherwise use default
    final appBarTitle = _isSearch
        ? 'search'.tr
        : (widget.params?.title ?? 'listingTitle'.tr);

    return Scaffold(
      appBar: CommonAppBar(
        title: appBarTitle,
        showBackButton: widget.params?.showBackButton ?? true,
      ),
      body: Column(
        children: [
          // Search bar with filter button (hide filter in search mode)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    borderRadius: 4,
                    showBorder: true,
                    borderColor: Theme.of(context).colorScheme.outlineVariant,
                    filled: false,
                  ),
                ),
                // if (!_isSearch) ...[
                //   const SizedBox(width: 12),
                //   IconButton(
                //     onPressed: () => _showFilterPage(context, ref, listingState),
                //     icon: Icon(
                //       Icons.filter_list,
                //       color: Theme.of(context).colorScheme.onSurface,
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
          // Content - show loading or listview with all states inside
          Expanded(
            child: (listingState.isLoading || listingState.data == null)
                ? (listingState.isLoading
                    ? const CommonCircularProgessIndicator()
                    : const SizedBox.shrink())
                : Semantics(
                    liveRegion: listingState.items.isEmpty,
                    label: listingState.items.isEmpty
                        ? (listingState.error != null
                              ? 'errorTitle'.tr
                              : 'noResults'.tr)
                        : null,
                    child: CommonRefreshableListView<ListingModel>(
                      items: listingState.items,
                      hasNextPage: listingState.hasNextPage,
                      isLoadingMore: listingState.isLoadingMore,
                      error: listingState.error,
                      emptyMessage: 'noResults'.tr,
                      errorMessage: 'errorTitle'.tr,
                      scrollController: _scrollController,
                      onRefresh: () => ref
                          .read(listingProviderFamily(_familyKey).notifier)
                          .refresh(
                            categorySlug: _isSearch
                                ? null
                                : widget.params?.categorySlug,
                          ),
                      itemBuilder: (context, listing, index) =>
                          ListingItemWidget(
                            listing: listing,
                            onTap: () => _handleListingTap(listing),
                          ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterPage(BuildContext context, WidgetRef ref, listingState) {
    // Navigate to listing filter page with family key and category slug
    final categorySlug = widget.params?.categorySlug ?? 'default';
    context.pushNamed(
      AppRouteConstants.featureListingFilter.name,
      extra: {'familyKey': _familyKey, 'categorySlug': categorySlug},
    );
  }
}
