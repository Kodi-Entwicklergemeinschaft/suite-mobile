import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/common_calendar.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/profile/presentation/profile_bottom_sheet.dart';
import 'package:template_c/feat/search/controller/search_controller.dart';
import 'package:template_c/feat/search/filter/search_filter_controller.dart';
import 'package:template_c/feat/search/filter/search_filter_sheet.dart';
import 'package:template_c/feat/search/presentation/search_app_bar.dart';
import 'package:template_c/feat/search/presentation/search_banner_widget.dart';
import 'package:template_c/feat/search/presentation/recent_search_view.dart';
import 'package:template_c/feat/search/presentation/search_filter_bottom_sheet.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:theme/theme.dart';

class SearchScreen extends BaseStatefulWidget {
  const SearchScreen({super.key});

  @override
  String get screenName => RouteConstant.search.name;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends BaseStatefulWidgetState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    Future.microtask(() {
      ref.read(searchControllerProvider.notifier).search();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _textController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchControllerProvider.notifier).loadMore();
    }
  }

  bool get _isSearchActive {
    final s = ref.watch(searchControllerProvider);
    return s.searchQuery.isNotEmpty ||
        s.isLocationFilterActive ||
        s.isFreeEntryFilterActive ||
        s.dateFilter != null;
  }

  String _primaryLocationLabel(String? address) {
    final normalized = address?.trim() ?? '';
    if (normalized.isEmpty) return 'filter_location'.tr;
    return normalized.split(',').first.trim();
  }

  Future<void> _submitSearch(String value) async {
    final query = value.trim();
    _textController.value = _textController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
      composing: TextRange.empty,
    );
    await ref.read(searchControllerProvider.notifier).submitSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Theme.of(context).dividerColor;
    final invertedColor = Theme.of(context).extension<AppTextColors>()!.normal;

    return Scaffold(
      body: Column(
        children: [
          if (_isSearchFocused)
            SizedBox(height: MediaQuery.of(context).padding.top)
          else
            SearchAppBar(onProfileTap: () => showProfileBottomSheet(context)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.search();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        top: 12.h,
                        bottom: 10.h,
                      ),
                      child: _buildSearchRow(
                        context,
                        dividerColor,
                        invertedColor,
                      ),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
                      child: _buildFilterChips(context, state, controller),
                    ),
                  ),

                  // Recent search overlay — shown when field is focused and empty
                  if (_isSearchFocused &&
                      state.searchQuery.isEmpty &&
                      state.recentQueries.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: RecentSearchView(
                        queries: state.recentQueries,
                        onItemTap: (query) async {
                          _textController.value = _textController.value
                              .copyWith(
                                text: query,
                                selection: TextSelection.collapsed(
                                  offset: query.length,
                                ),
                                composing: TextRange.empty,
                              );
                          _searchFocusNode.unfocus();
                          await controller.selectRecentQuery(query);
                        },
                        onRemove: controller.removeRecentQuery,
                        onClearAll: controller.clearRecentQueries,
                      ),
                    ),
                  ] else ...[
                    // Banner — hidden when search/filter is active
                    if (!_isSearchActive)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverToBoxAdapter(child: SearchBannerWidget()),
                      ),

                    // Section header
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        top: 24.h,
                        bottom: 16.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _isSearchActive
                            ? CommonText(
                                titleText: 'search_all_events'.tr,
                                textStyle: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        titleText: 'search_all_events'.tr,
                                        textStyle: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (state.stateConstant ==
                                              StateConstant.success &&
                                          state.totalCount != null)
                                        CommonText(
                                          titleText:
                                              '${state.totalCount! >= 200 ? '200+' : state.totalCount} ${'search_events_count'.tr}',
                                          textStyle: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showSearchFilterBottomSheet(
                                        context,
                                        onSelected: (option) async {
                                          await controller.updateSortOption(
                                            option,
                                          );
                                        },
                                      );
                                    },
                                    child: CommonImage(
                                      imagePath: 'assets/svg/fav_filter.svg',
                                      color: Theme.of(
                                        context,
                                      ).extension<AppTextColors>()!.normal,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Content
                    if (state.stateConstant == StateConstant.loading)
                      SliverToBoxAdapter(child: TemplateCLoader(height: 200.h))
                    else if (state.items.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 40.h,
                          ),
                          child: Center(
                            child: CommonText(
                              titleText: 'listing_no_results'.tr,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      _buildList(context),

                    // Pagination loader
                    if (state.isPaginationLoading)
                      SliverToBoxAdapter(child: TemplateCLoader(height: 80.h)),
                  ],

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 80.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(
    BuildContext context,
    Color dividerColor,
    Color iconColor,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            controller: _textController,
            focusNode: _searchFocusNode,
            onChanged: ref
                .read(searchControllerProvider.notifier)
                .updateSearchQuery,
            onSubmitted: _submitSearch,
            textInputAction: TextInputAction.search,
            hintText: _isSearchFocused ? null : 'search_hint'.tr,
            hintTextColor: isLight
                ? TemplateCColors.textDark
                : TemplateCColors.textAndIconWhite,
            hintFontSize: 14.sp,
            hintFontWeight: FontWeight.w500,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SvgPicture.asset(
                'assets/svg/search.svg',
                width: 18.sp,
                height: 18.sp,
                colorFilter: ColorFilter.mode(
                  isLight
                      ? TemplateCColors.textDark
                      : TemplateCColors.textAndIconWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
            filled: true,
            fillColor: isLight ? null : TemplateCColors.darkModeCardBg,
            borderRadius: 12,
            focusColor: primaryColor,
            borderColor: _isSearchFocused ? primaryColor : dividerColor,
            showClearButton: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
        if (_isSearchFocused) ...[
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {
              _textController.clear();
              _searchFocusNode.unfocus();
              ref.read(searchControllerProvider.notifier).updateSearchQuery('');
            },
            child: CommonText(
              titleText: 'calendar_cancel'.tr,
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, state, controller) {
    final selectedInterests = ref
        .watch(searchFilterControllerProvider)
        .selectedInterests;
    final filterCount =
        selectedInterests.length +
        (state.dateFilter != null ? 1 : 0) +
        // (state.isFreeEntryFilterActive ? 1 : 0) +
        (state.isLocationFilterActive ? 1 : 0);

    return SizedBox(
      height: 42.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            // Circular filter chip with badge
            GestureDetector(
              onTap: () => showSearchFilterSheet(
                context,
                onDateRemoved: () async {
                  await ref
                      .read(searchControllerProvider.notifier)
                      .updateDateFilter(null);
                },
                onFreeEntryRemoved: () {
                  ref.read(searchControllerProvider.notifier).toggleFreeEntry();
                },
                onLocationRemoved: () {
                  ref
                      .read(searchControllerProvider.notifier)
                      .clearLocationFilter();
                },
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42.w,
                    height: 42.h,
                    padding: EdgeInsets.symmetric(
                      vertical: 11.h,
                      horizontal: 11.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45.5.r),
                      color: filterCount > 0
                          ? Theme.of(context).colorScheme.secondary
                          : context.templateColors.chipBg,
                      border: Border.all(
                        color: Theme.of(context).dividerTheme.color!,
                        width: 1.0,
                      ),
                    ),
                    child: CommonImage(
                      color: filterCount > 0
                          ? Colors.black
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      imagePath: 'assets/svg/filter_icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (filterCount > 0)
                    Positioned(
                      top: -4.h,
                      right: -4.w,
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: CommonText(
                          titleText: '$filterCount',
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Selected interest chips inline
            ...selectedInterests.map(
              (interest) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildActiveChip(
                  context,
                  interest.title ?? '',
                  onRemove: () {
                    ref
                        .read(searchFilterControllerProvider.notifier)
                        .removeInterest(interest);
                    final remaining = ref
                        .read(searchFilterControllerProvider)
                        .selectedInterests
                        .map((i) => i.slug ?? '')
                        .toList();
                    ref
                        .read(searchControllerProvider.notifier)
                        .updateCategoryFilter(remaining);
                  },
                ),
              ),
            ),
            // Location — active chip when filter is on
            if (state.isLocationFilterActive) ...[
              _buildActiveChip(
                context,
                _primaryLocationLabel(state.filterLocationName),
                onRemove: () => controller.clearLocationFilter(),
              ),
              SizedBox(width: 8.w),
            ],
            // Date — active chip first, inactive chip at end
            if (state.dateFilter != null) ...[
              _buildActiveChip(
                context,
                formatDateRangeLabel(
                  state.dateFilter!.start,
                  state.dateFilter!.end,
                ),
                onRemove: () => controller.updateDateFilter(null),
              ),
              SizedBox(width: 8.w),
            ],
            // Free entry — active chip first, inactive chip at end
            // if (state.isFreeEntryFilterActive) ...[
            //   _buildActiveChip(
            //     context,
            //     'filter_free_entry'.tr,
            //     onRemove: controller.toggleFreeEntry,
            //   ),
            //   SizedBox(width: 8.w),
            // ],
            // Ort (only visible when location filter is not active)
            if (!state.isLocationFilterActive) ...[
              GestureDetector(
                onTap: () async {
                  final result = await context
                      .pushNamed<(double, double, double, String)>(
                        RouteConstant.locationOnboarding.name,
                        extra: LocationOnboardingParams(
                          isSkip: true,
                          onConfirm: (_) {},
                          isSearchFilter: true,
                        ),
                      );
                  if (result != null && context.mounted) {
                    final (lat, lon, radius, name) = result;
                    await ref
                        .read(searchControllerProvider.notifier)
                        .activateLocationFilter(
                          lat: lat,
                          lon: lon,
                          radiusKm: radius,
                          locationName: name,
                        );
                  }
                },
                child: _buildChip(
                  context,
                  'filter_location'.tr,
                  false,
                  showChevron: true,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            // Datum (only when not selected)
            if (state.dateFilter == null)
              GestureDetector(
                onTap: () async {
                  final range = await CommonCalendar.show<DateTimeRange>(
                    context,
                    selectionMode: CalendarSelectionMode.range,
                  );
                  await controller.updateDateFilter(range);
                },
                child: _buildChip(
                  context,
                  'filter_date'.tr,
                  false,
                  showChevron: true,
                ),
              ),
            if (state.dateFilter == null) SizedBox(width: 8.w),
            // Eintritt frei (only when not selected)
            // if (!state.isFreeEntryFilterActive)
            //   GestureDetector(
            //     onTap: controller.toggleFreeEntry,
            //     child: _buildChip(context, 'filter_free_entry'.tr, false),
            //   ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    bool isActive, {
    bool showChevron = false,
  }) {
    final bgColor = isActive
        ? Theme.of(context).colorScheme.secondary
        : context.templateColors.chipBg;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        color: bgColor,
        border: Border.all(
          color: Theme.of(context).dividerTheme.color!,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            titleText: label,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1,
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, size: 16.sp),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveChip(
    BuildContext context,
    String label, {
    required VoidCallback onRemove,
  }) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(
            titleText: label,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: const Color(0xFF151B23),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF151B23)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final items = ref.watch(searchControllerProvider).items;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: ListingItemCard.compact(
              model: item,
              onTap: item.id == null
                  ? null
                  : () async {
                      await ref
                          .read(searchControllerProvider.notifier)
                          .persistCurrentQueryIfEligible();
                      if (!context.mounted) return;
                      context.pushNamed(
                        RouteConstant.listingDetail.name,
                        pathParameters: {'id': item.id!},
                      );
                    },
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}
