import 'dart:ui' show ImageFilter;

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/actions/app_bar_actions.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/fav/controller/fav_controller.dart';
import 'package:template_c/feat/fav/data/model/response_model/get_fav_categories_response_model.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_calendar_view.dart';
import 'package:template_c/core/widgets/app_bar_profile_pill.dart';
import 'package:template_c/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_c/feat/profile/presentation/profile_bottom_sheet.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_chips_row.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_view.dart';
import 'package:template_c/feat/fav/presentation/widgets/event_view.dart';
import 'package:template_c/feat/search/presentation/search_screen.dart';
import 'package:theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/router/route_constant.dart';

class FavScreen extends BaseStatefulWidget {
  const FavScreen({super.key});

  @override
  String get screenName => RouteConstant.fav.name;

  @override
  ConsumerState<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends BaseStatefulWidgetState<FavScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // True when the organizer tab is selected in the dropdown.
  bool _isOrganizerMode = false;

  // Whether the first-category auto-select has already been applied.
  bool _autoSelectApplied = false;

  bool _isDropdownOpen = false;

  late AnimationController _calendarAnimController;
  late Animation<Offset> _appBarSlide;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _calendarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final curve = CurvedAnimation(
      parent: _calendarAnimController,
      curve: Curves.easeInOut,
    );
    _appBarSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(curve);
    _contentSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(curve);

    Future.microtask(() async {
      final notifier = ref.read(favScreenControllerProvider.notifier);
      await notifier.fetchDropdownCategories();
      await notifier.getFavListing();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _calendarAnimController.dispose();
    super.dispose();
  }

  void _navigateToSearch() {
    final navState = ref.read(bottomNavigationControllerProvider);
    final searchIndex = navState.screenList.indexWhere(
      (s) => s is SearchScreen,
    );
    if (searchIndex != -1) {
      ref
          .read(bottomNavigationControllerProvider.notifier)
          .updateSelectedIndex(searchIndex);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(favScreenControllerProvider.notifier).loadMoreFav();
    }
  }

  /// Resolves the initial mode once categories arrive (one-shot):
  /// - No categories at all → start in organizer mode (e.g. fresh restart
  ///   with no favorites left), so the placeholder "Events" entry never shows.
  /// - Otherwise → auto-select the first category.
  void _maybeAutoSelect(List<FavCategoryItemModel> categories) {
    if (_autoSelectApplied) return;
    // Wait until the categories fetch has resolved before deciding — an empty
    // list while still loading would wrongly flip us into organizer mode.
    if (ref.read(favScreenControllerProvider).stateConstant ==
        StateConstant.loading) {
      return;
    }
    if (categories.isEmpty) {
      _autoSelectApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _isOrganizerMode = true);
      });
      return;
    }
    final firstSlug = categories.first.slug;
    if (firstSlug == null || firstSlug.isEmpty) return;
    _autoSelectApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(favScreenControllerProvider.notifier)
          .updateSelectedCategory(firstSlug, allowToggle: false);
    });
  }

  /// Resolves the parent category for [slug] from [categories].
  /// If slug is a top-level category → returns it directly.
  /// If slug is a child → returns the parent.
  FavCategoryItemModel? _resolveParentCategory(
    String? slug,
    List<FavCategoryItemModel> categories,
  ) {
    if (slug == null || slug.isEmpty) return null;
    for (final cat in categories) {
      if (cat.slug == slug) return cat;
      if (cat.children.any((ch) => ch.slug == slug)) return cat;
    }
    return null;
  }

  String _appBarTitle(
    List<FavCategoryItemModel> categories,
    String activeSlug,
  ) {
    if (_isOrganizerMode) return 'organizer'.tr;
    final parent = _resolveParentCategory(activeSlug, categories);
    return parent?.title ?? 'events_dropdown'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(favScreenControllerProvider.notifier);
    final state = ref.watch(favScreenControllerProvider);

    // Auto-select first category once categories arrive.
    _maybeAutoSelect(state.dropdownCategories);

    // When the last category empties out, the controller flags this — switch
    // the screen to organizer mode and reset the one-shot flag.
    ref.listen(favScreenControllerProvider.select((s) => s.switchToOrganizer), (
      previous,
      next,
    ) {
      if (next == true && !_isOrganizerMode) {
        setState(() => _isOrganizerMode = true);
        ref
            .read(favScreenControllerProvider.notifier)
            .consumeSwitchToOrganizer();
      }
    });

    // The active slug (parent or child) lives in the controller. Derive the
    // displayed parent category from it — single source of truth, no local sync.
    final activeSlug = state.selectedFavCategory;
    final selectedCategory = _resolveParentCategory(
      activeSlug,
      state.dropdownCategories,
    );
    final subcategoryChips = (selectedCategory?.children ?? [])
        .where((c) => c.slug?.isNotEmpty == true)
        .map((c) => (label: c.title ?? '', slug: c.slug!))
        .toList();

    return Scaffold(
      body: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  SlideTransition(
                    position: _appBarSlide,
                    child: _buildFavAppBarWidget(
                      context,
                      state.dropdownCategories,
                      activeSlug,
                    ),
                  ),
                  Expanded(
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isOrganizerMode)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.w,
                                    right: 16.w,
                                    top: 16.h,
                                  ),
                                  child: FavChipsRow(
                                    onCalendarTap: () {
                                      controller.updateIsCalendarOpenState(
                                        true,
                                      );
                                      _calendarAnimController.forward();
                                    },
                                    // Always custom chips (subcategories of the
                                    // selected category) — empty when none, so the
                                    // old meta.categories fallback never shows.
                                    customChips: subcategoryChips,
                                    customSelectedSlug:
                                        state.selectedFavCategory,
                                    onCustomChipTap: (slug) =>
                                        controller.updateSelectedCategory(slug),
                                  ),
                                ),
                              Expanded(
                                child: _isOrganizerMode
                                    ? RefreshIndicator(
                                        onRefresh: () async {},
                                        child: OrganizerView(
                                          onNavigateToSearch: _navigateToSearch,
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () async =>
                                            controller.getFavListing(),
                                        child: EventView(
                                          scrollController: _scrollController,
                                          onNavigateToSearch: _navigateToSearch,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          if (!_isOrganizerMode &&
                              state.stateConstant == StateConstant.loading)
                            const TemplateCLoader(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isDropdownOpen) ...[
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => setState(() => _isDropdownOpen = false),
                ),
              ),
              Positioned(
                left: 16.w,
                top: MediaQuery.of(context).padding.top + kToolbarHeight - 8.h,
                child: _buildDropdownCard(
                  state.dropdownCategories,
                  selectedCategory?.slug,
                ),
              ),
            ],

            if (state.isCalendarOpen)
              Positioned.fill(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _calendarAnimController,
                    curve: Curves.easeIn,
                  ),
                  child: FavCalendarView(
                    onClose: () {
                      _calendarAnimController.reverse().then((_) {
                        ref
                            .read(favScreenControllerProvider.notifier)
                            .updateIsCalendarOpenState(false);
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard(
    List<FavCategoryItemModel> categories,
    String? activeParentSlug,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Theme.of(context).dividerColor;
    final bgColor = isDark ? const Color(0xB20B0F13) : const Color(0x80FFFFFF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(
          width: 212.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: dividerColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 52.4,
                offset: Offset(0, 8.38),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dynamic category entries from API
              ...categories.asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                final slug = cat.slug ?? '';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index > 0) SizedBox(height: 32.h),
                    _buildDropdownItem(
                      label: cat.title ?? '',
                      iconPath: 'assets/svg/event_icon.svg',
                      isSelected: !_isOrganizerMode && activeParentSlug == slug,
                      onTap: () {
                        setState(() {
                          _isOrganizerMode = false;
                          _isDropdownOpen = false;
                        });
                        ref
                            .read(favScreenControllerProvider.notifier)
                            .updateSelectedCategory(slug, allowToggle: false);
                      },
                    ),
                  ],
                );
              }),

              // Fallback when categories haven't loaded yet. Suppressed in
              // organizer mode — once the last category empties out there are
              // no events left, so the placeholder "Events" entry must not show.
              if (categories.isEmpty && !_isOrganizerMode)
                _buildDropdownItem(
                  label: 'events_dropdown'.tr,
                  iconPath: 'assets/svg/event_icon.svg',
                  isSelected: !_isOrganizerMode,
                  onTap: () => setState(() => _isDropdownOpen = false),
                ),

              // Spacer above "Organizer" only when there's an entry above it.
              if (categories.isNotEmpty || !_isOrganizerMode)
                SizedBox(height: 32.h),

              // Organizer — always last
              _buildDropdownItem(
                label: 'organizer'.tr,
                iconPath: 'assets/svg/organizer_icon.svg',
                isSelected: _isOrganizerMode,
                onTap: () {
                  setState(() {
                    _isOrganizerMode = true;
                    _isDropdownOpen = false;
                  });
                  // Clear fav list so switching back to a category shows no stale data.
                  ref.read(favScreenControllerProvider.notifier).clearFavList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).extension<AppTextColors>()!.normal;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          SizedBox(width: 12.w),
          CommonText(
            titleText: label,
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.0,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavAppBarWidget(
    BuildContext context,
    List<FavCategoryItemModel> categories,
    String activeSlug,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final invertedColor = Theme.of(context).extension<AppTextColors>()!.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding),
        SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _isDropdownOpen = !_isDropdownOpen),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonText(
                        titleText: _appBarTitle(categories, activeSlug),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 8.w),
                      SvgPicture.asset(
                        'assets/icons/chevron_down.svg',
                        width: 24.w,
                        height: 24.h,
                        colorFilter: ColorFilter.mode(
                          invertedColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (AppBarActions.isPoiIncluded) ...[
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(AppBarActions.poiRoute);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/search_icon.svg',
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                AppBarProfilePill(onTap: () => showProfileBottomSheet(context)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
