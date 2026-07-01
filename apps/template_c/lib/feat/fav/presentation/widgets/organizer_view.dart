import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/fav/presentation/organizer_detail_screen.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_section_header.dart';
import 'package:template_c/feat/fav/presentation/widgets/fav_banner_widget.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_card_widget.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_menu_row_card.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_unsubscribe_sheet.dart';
import 'package:template_c/feat/organizer/controller/organizer_list_controller.dart';
import 'package:template_c/feat/organizer/controller/organizer_follow_toggle_controller.dart';
import 'package:template_c/feat/organizer/state/organizer_list_state.dart';
import 'package:theme/theme.dart';

class OrganizerView extends BaseStatefulWidget {
  const OrganizerView({super.key, this.onNavigateToSearch});

  final VoidCallback? onNavigateToSearch;

  @override
  ConsumerState<OrganizerView> createState() => _OrganizerViewState();
}

class _OrganizerViewState extends BaseStatefulWidgetState<OrganizerView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(organizerListControllerProvider.notifier).fetchOrganizers();
      ref.read(organizerListControllerProvider.notifier).fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final organizerState = ref.watch(organizerListControllerProvider);

    final organizers = organizerState.organizers;
    final subscribedCount = organizerState.subscribedCount;
    final showRecommendations =
        organizerState.recommendationsState == StateConstant.success &&
        organizerState.recommendations.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(organizerListControllerProvider.notifier).fetchOrganizers();
        ref
            .read(organizerListControllerProvider.notifier)
            .fetchRecommendations();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FavSectionHeader(
              title: 'organizer_subscriptions_title'.tr,
              subtitle: subscribedCount != null
                  ? '$subscribedCount ${'organizer_subscriptions_subtitle_suffix'.tr}'
                  : null,
            ),
          ),

          // ── Loading / Empty / Rows ───────────────────────────────────────
          if (organizerState.stateConstant == StateConstant.loading)
            SliverToBoxAdapter(child: TemplateCLoader(height: 300.h))
          else if (organizers.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(context))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = organizers[index];
                final isLast = index == organizers.length - 1;
                final isSubscribed = item.isFollowing ?? false;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OrganizerMenuRowCard(
                        name: item.displayName ?? item.username ?? '',
                        category: item.summary ?? item.username,
                        logoUrl: item.avatar,
                        isSubscribed: isSubscribed,
                        onSubscribeTap: () {
                          if (isSubscribed) {
                            showOrganizerUnsubscribeSheet(
                              context,
                              name: item.displayName ?? item.username ?? '',
                              category: item.summary ?? item.username,
                              logoUrl: item.avatar,
                              onConfirmUnsubscribe: () => ref
                                  .read(organizerToggleControllerProvider)
                                  .toggle(item.id ?? '', subscribe: false),
                            );
                          } else {
                            ref
                                .read(organizerToggleControllerProvider)
                                .toggle(item.id ?? '', subscribe: true);
                          }
                        },
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganizerDetailScreen(
                              id: item.id ?? '',
                              name: item.displayName ?? item.username ?? '',
                              category: item.summary ?? item.username,
                              logoUrl: item.avatar,
                              initiallySubscribed: isSubscribed,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, thickness: 1),
                    ],
                  ),
                );
              }, childCount: organizers.length),
            ),

          // ── Load More button ─────────────────────────────────────────────
          if (organizerState.hasMore &&
              organizerState.stateConstant == StateConstant.success)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: organizerState.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: () => ref
                            .read(organizerListControllerProvider.notifier)
                            .loadMore(),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonText(
                                titleText: 'load_more'.tr,
                                textStyle: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_downward,
                                size: 18.sp,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

          // ── Banner ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: FavBannerWidget(
                badge: BadgeIconWidget(
                  foregroundIconPath: 'assets/svg/fav_organizer_screen_banner_image.svg',
                ),
                tag: 'organizer_banner_tag'.tr,
                descriptionHighlight:
                    'organizer_banner_description_highlight'.tr,
                descriptionMiddle: 'organizer_banner_description_middle'.tr,
                descriptionHighlight2:
                    'organizer_banner_description_highlight2'.tr,
                descriptionSuffix: 'organizer_banner_description_suffix'.tr,
                actionText: 'organizer_banner_action'.tr,
                onActionTap: widget.onNavigateToSearch,
              ),
            ),
          ),

          // ── Recommendations ──────────────────────────────────────────────
          if (showRecommendations)
            SliverToBoxAdapter(
              child: _buildDiscoverSection(context, organizerState),
            ),

          // ── Bottom padding ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 80.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 48.h),
          SvgPicture.asset(
            'assets/svg/organizer_icon.svg',
            width: 64.w,
            height: 64.h,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<AppTextColors>()!.normal,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 16.h),
          CommonText(
            titleText: 'no_organizers_available'.tr,
            textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(
    BuildContext context,
    OrganizerListState organizerState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: CommonText(
            titleText: 'organizer_discover_title'.tr,
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
        ),
        SizedBox(
          height: 290.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            itemCount: organizerState.recommendations.length,
            itemBuilder: (context, index) {
              final item = organizerState.recommendations[index];
              final isLast = index == organizerState.recommendations.length - 1;
              final isSubscribed = item.isFollowing ?? false;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
                child: OrganizerCardWidget(
                  name: item.displayName ?? item.username ?? '',
                  category: item.summary ?? item.username,
                  logoUrl: item.avatar,
                  isSubscribed: isSubscribed,
                  onSubscribeTap: () => ref
                      .read(organizerToggleControllerProvider)
                      .toggle(item.id ?? '', subscribe: !isSubscribed),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrganizerDetailScreen(
                        id: item.id ?? '',
                        name: item.displayName ?? item.username ?? '',
                        category: item.summary ?? item.username,
                        logoUrl: item.avatar,
                        initiallySubscribed: isSubscribed,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
