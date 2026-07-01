import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';
import 'package:template_c/feat/fav/constant/fav_filter_contant.dart';
import 'package:template_c/feat/fav/controller/fav_controller.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_banner_widget.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_filter_bottom_sheet.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_section_header.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:theme/theme.dart';

class EventView extends BaseStatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onNavigateToSearch;

  const EventView({
    super.key,
    required this.scrollController,
    required this.onNavigateToSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favScreenControllerProvider);
    final controller = ref.read(favScreenControllerProvider.notifier);

    ref.listen(favScreenControllerProvider, (previous, next) {
      if (next.stateConstant == StateConstant.error) {
        AppSnackBar.showError(context, next.errorMessage);
      }
    });

    final items = state.listOfFav.toList();

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: FavSectionHeader(
            title: 'you_upcoming_events'.tr,
            subtitle: "${state.listOfFav.length} ${'saved_events'.tr}",
            onFilterTap: () {
              showFavFilterBottomSheet(
                context,
                selected: state.favSortOption,
                onSelected: (FavSortOption value) async {
                  await controller.updateFilter(value);
                },
              );
            },
          ),
        ),
        if (items.isEmpty && state.stateConstant != StateConstant.loading)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 48.h),
                  _buildEmptyState(context),
                  FavBannerWidget(
                  badge: BadgeIconWidget(
                    foregroundIconPath: 'assets/svg/fav_event_screen_banner_image.svg',
                  ),
                  tag: 'fav_banner_tag'.tr,
                  descriptionHighlight: 'fav_banner_description_highlight'.tr,
                  descriptionMiddle: 'fav_banner_description_middle'.tr,
                  descriptionHighlight2: 'fav_banner_description_highlight2'.tr,
                  descriptionSuffix: 'fav_banner_description_suffix'.tr,
                  actionText: 'fav_banner_action'.tr,
                  onActionTap: onNavigateToSearch,
                ),
                ],
              ),
            ),
          )
        else
          _buildList(context, ref),
        if (state.isPaginationLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80.h),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favScreenControllerProvider);
    final controller = ref.read(favScreenControllerProvider.notifier);

    final items = state.listOfFav;

    // Banner appears after the 4th item (index 4), or at the end if fewer than 4 items
    final bannerIndex = items.length >= 4 ? 4 : items.length;
    final totalCount = items.length + 1; // +1 for the banner slot

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == bannerIndex) {
            return FavBannerWidget(
                  badge: BadgeIconWidget(
                    foregroundIconPath: 'assets/svg/fav_event_screen_banner_image.svg',
                
                  ),
                  tag: 'fav_banner_tag'.tr,
                  descriptionHighlight: 'fav_banner_description_highlight'.tr,
                  descriptionMiddle: 'fav_banner_description_middle'.tr,
                  descriptionHighlight2: 'fav_banner_description_highlight2'.tr,
                  descriptionSuffix: 'fav_banner_description_suffix'.tr,
                  actionText: 'fav_banner_action'.tr,
                  onActionTap: onNavigateToSearch,
                );
          }

          final itemIndex = index > bannerIndex ? index - 1 : index;
          final item = items[itemIndex];
          final isLast = index == totalCount - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: ListingItemCard(
              model: item,
              onTap: item.id == null
                  ? null
                  : () {
                      context.pushNamed(
                        RouteConstant.listingDetail.name,
                        pathParameters: {'id': item.id!},
                      );
                    },
              onFavoriteTap: item.id != null
                  ? () => controller.removeFav(id: item.id!)
                  : null,
            ),
          );
        }, childCount: totalCount),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/svg/fav.svg',
          width: 64.w,
          height: 64.h,
          colorFilter: ColorFilter.mode(
            Theme.of(context).extension<AppTextColors>()!.normal,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(height: 16.h),
        CommonText(
          titleText: 'no_favourites_available'.tr,
          textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        CommonText(
          titleText: 'no_favourites_description'.tr,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<AppTextColors>()!.inverse,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
