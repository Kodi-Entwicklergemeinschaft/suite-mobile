import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/fav/controller/fav_controller.dart';
import 'package:template_a/feat/fav/state/fav_state.dart';
import 'package:template_a/feat/filter/presentation/category_filter_bottom_sheet.dart';
import 'package:template_a/feat/filter/presentation/date_range_filter_bottom_sheet.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';

class FavScreen extends BaseStatefulWidget {
  final String? initialCategory;
  final String? title;

  const FavScreen({super.key, this.initialCategory, this.title});

  @override
  String get screenName => 'favorites';

  @override
  ConsumerState<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends BaseStatefulWidgetState<FavScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(favScreenControllerProvider.notifier).getFavListing(
        category: widget.initialCategory,
      );
    });
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.extentAfter < 200) {
      ref.read(favScreenControllerProvider.notifier).loadMoreFav();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _parseColor(String? hex, ThemeData theme) {
    if (hex == null || hex.isEmpty) return theme.colorScheme.primary;
    try {
      final cleaned = hex.startsWith('#') ? hex.replaceFirst('#', '0xff') : '0xff$hex';
      return Color(int.parse(cleaned));
    } catch (_) {
      return theme.colorScheme.primary;
    }
  }

  Future<void> _onFilterTap(FavState state) async {
    if (state.isEventCategory) {
      final result = await showDateRangeFilterBottomSheet(context: context);
      if (result != null && mounted) {
        ref.read(favScreenControllerProvider.notifier).getFavListing(
          startDate: result['start'],
          endDate: result['end'],
        );
      }
    } else {
      final slug = state.selectedFavCategory;
      final result = await showCategoryFilterBottomSheet(
        context: context,
        categorySlug: slug,
      );
      if (result != null && mounted) {
        ref.read(favScreenControllerProvider.notifier).getFavListing();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favScreenControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: CommonText(
          titleText: widget.title ?? 'account_favorites_title'.tr,
          textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'filter'.tr,
            child: GestureDetector(
              onTap: () => _onFilterTap(state),
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: ExcludeSemantics(
                  child: CommonImage(
                    imagePath: Images.filterIcon,
                    width: 48,
                    height: 48,
                    label: 'filter_icon_label'.tr,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.favCategoryList.isNotEmpty) _buildCategoryChips(state, theme),
          Expanded(child: _buildBody(state, theme)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(FavState state, ThemeData theme) {
    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.favCategoryList.length,
        itemBuilder: (_, index) {
          final cat = state.favCategoryList[index];
          final isSelected = state.selectedFavCategory == (cat.slug ?? '');
          final titleColor = _parseColor(cat.headerBackgroundColor, theme);
          return CommonImageTextCard(
            title: cat.title ?? '',
            imageUrl: cat.imageUrl ?? '',
            titleColor: titleColor,
            isSelected: isSelected,
            onTap: () => ref
                .read(favScreenControllerProvider.notifier)
                .selectCategory(cat.slug ?? ''),
          );
        },
      ),
    );
  }

  Widget _buildBody(FavState state, ThemeData theme) {
    if (state.stateConstant == StateConstant.loading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (state.stateConstant == StateConstant.error && state.listOfFav.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: theme.colorScheme.error),
            SizedBox(height: 12.h),
            CommonText(
              titleText: state.errorMessage,
              textStyle: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () =>
                  ref.read(favScreenControllerProvider.notifier).getFavListing(),
              child: Text('retryButton'.tr),
            ),
          ],
        ),
      );
    }

    if (state.listOfFav.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(favScreenControllerProvider.notifier).getFavListing(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount:
            state.listOfFav.length + (state.isPaginationLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.listOfFav.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child:
                    CircularProgressIndicator(color: theme.colorScheme.primary),
              ),
            );
          }
          final item = state.listOfFav[index];
          return _FavListingCard(
            listing: item,
            onTap: () => _openDetail(context, item),
            onRemove: () => ref
                .read(favScreenControllerProvider.notifier)
                .removeFav(item.id ?? ''),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 72.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            CommonText(
              titleText: 'no_fav_listing'.tr,
              textAlign: TextAlign.center,
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
    );
  }
}

class _FavListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavListingCard({
    required this.listing,
    required this.onTap,
    required this.onRemove,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = listing.firstImageUrl ?? '';
    final fallbackImageUrl = listing.categoryFallbackImage;
    final dateRange = listing.eventStart != null
        ? '${_formatDate(listing.eventStart)}'
            '${listing.eventEnd != null ? ' - ${_formatDate(listing.eventEnd)}' : ''}'
        : '';

    final semanticLabel = [listing.title, listing.address]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100.w,
              height: 100.h,
              child: imageUrl.isNotEmpty
                  ? CommonImage(
                      imagePath: imageUrl,
                      fit: BoxFit.cover,
                      width: 100.w,
                      height: 100.h,
                      errorWidget: fallbackImageUrl?.isNotEmpty == true
                          ? (context, error, stack) => CommonImage(
                                imagePath: fallbackImageUrl!,
                                fit: BoxFit.cover,
                                width: 100.w,
                                height: 100.h,
                              )
                          : null,
                    )
                  : Container(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      child: Icon(Icons.image, size: 32.sp, color: Colors.white30),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      titleText: listing.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (dateRange.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CommonText(
                              titleText: dateRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (listing.address != null && listing.address!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CommonText(
                              titleText: listing.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'remove_from_favourites'.tr,
              child: IconButton(
                onPressed: onRemove,
                icon: ExcludeSemantics(
                  child: Icon(Icons.favorite, color: Colors.red, size: 22.sp),
                ),
                padding: EdgeInsets.all(10.h),
                constraints: BoxConstraints(minWidth: 44.h, minHeight: 44.h),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
