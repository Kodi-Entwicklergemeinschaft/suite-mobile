import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/feat/fav/controller/fav_category_screen_controller.dart';
import 'package:template_a/feat/fav/state/fav_category_state.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';

class FavCategoryScreen extends BaseStatefulWidget {
  final String categorySlug;
  final String screenTitle;
  final String? headerColorHex;

  const FavCategoryScreen({
    super.key,
    required this.categorySlug,
    required this.screenTitle,
    this.headerColorHex,
  });

  @override
  String get screenName => 'favorite_category';

  @override
  ConsumerState<FavCategoryScreen> createState() => _FavCategoryScreenState();
}

class _FavCategoryScreenState extends BaseStatefulWidgetState<FavCategoryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favCategoryScreenProvider(widget.categorySlug).notifier).load();
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      ref.read(favCategoryScreenProvider(widget.categorySlug).notifier).loadMore();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query != _searchQuery) {
      setState(() => _searchQuery = query);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String? hex, BuildContext context) {
    if (hex == null || hex.isEmpty) return Theme.of(context).colorScheme.primary;
    try {
      final cleaned = hex.startsWith('#') ? hex.replaceFirst('#', '0xff') : '0xff$hex';
      return Color(int.parse(cleaned));
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  List<ListingModel> _applySearch(List<ListingModel> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((i) =>
            (i.title?.toLowerCase().contains(_searchQuery) ?? false) ||
            (i.address?.toLowerCase().contains(_searchQuery) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favCategoryScreenProvider(widget.categorySlug));
    final headerColor = _parseColor(widget.headerColorHex, context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context, headerColor),
            if (state.subCategories.isNotEmpty)
              _buildSubCategoryChips(state, headerColor),
            Expanded(child: _buildBody(state, headerColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color headerColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor =
        isDark ? TemplateAColors.lightModeBackground : theme.colorScheme.primary;
    final hintColor = isDark
        ? TemplateAColors.darkModeBackground.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.7);
    final iconColor =
        isDark ? TemplateAColors.darkModeBackground : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              fillColor: fillColor,
              minHeight: 48,
              maxHeight: 48,
              hintTextColor: hintColor,
              textColor:
                  isDark ? TemplateAColors.darkModeBackground : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
        ],
      ),
    );
  }

  Widget _buildSubCategoryChips(FavCategoryState state, Color headerColor) {
    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.subCategories.length,
        itemBuilder: (context, index) {
          final cat = state.subCategories[index];
          final isSelected =
              state.selectedSubCategory == (cat.slug ?? '');
          return CommonImageTextCard(
            title: cat.title ?? '',
            imageUrl: cat.imageUrl ?? '',
            titleColor: _parseColor(cat.headerBackgroundColor, context),
            isSelected: isSelected,
            onTap: () => ref
                .read(favCategoryScreenProvider(widget.categorySlug).notifier)
                .selectSubCategory(cat.slug ?? ''),
          );
        },
      ),
    );
  }

  Widget _buildBody(FavCategoryState state, Color headerColor) {
    if (state.stateConstant == StateConstant.loading && state.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: headerColor),
      );
    }

    if (state.stateConstant == StateConstant.error && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText(
              titleText: state.errorMessage,
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => ref
                  .read(favCategoryScreenProvider(widget.categorySlug).notifier)
                  .load(),
              child: Text('retryButton'.tr),
            ),
          ],
        ),
      );
    }

    final visibleItems = _applySearch(state.items);

    if (visibleItems.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'no_fav_listing'.tr,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(favCategoryScreenProvider(widget.categorySlug).notifier).load(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            sliver: SliverList.builder(
              itemCount:
                  visibleItems.length + (state.isPaginationLoading ? 1 : 0),
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
                  imageUrl: item.firstImageUrl ?? '',
                  name: item.title ?? '',
                  address: item.address,
                  todayOpeningStatus: _getDateRange(item),
                  headerColor: headerColor,
                  imageLabel: 'listing_image_label'.tr,
                  isFavourite: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: item),
                    ),
                  ),
                  onTapFavourite: () => ref
                      .read(
                          favCategoryScreenProvider(widget.categorySlug).notifier)
                      .removeFav(item.id ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _getDateRange(ListingModel item) {
    if (item.eventStart == null) return null;
    try {
      final start = DateTime.parse(item.eventStart!).toLocal();
      final startStr =
          '${start.day.toString().padLeft(2, '0')}.${start.month.toString().padLeft(2, '0')}.${start.year}';
      if (item.eventEnd == null) return startStr;
      final end = DateTime.parse(item.eventEnd!).toLocal();
      final endStr =
          '${end.day.toString().padLeft(2, '0')}.${end.month.toString().padLeft(2, '0')}.${end.year}';
      final startTime =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final endTime =
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      if (startStr == endStr) return '$startStr $startTime - $endTime';
      return '$startStr - $endStr';
    } catch (_) {
      return null;
    }
  }
}
