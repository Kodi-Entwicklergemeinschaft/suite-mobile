import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_details_appbar.dart';
import 'package:template_c/feat/fav/presentation/widgets/organizer_unsubscribe_sheet.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/feat/listing/ui/listing_detail_screen.dart';
import 'package:template_c/feat/organizer/controller/organizer_detail_controller.dart';
import 'package:template_c/feat/organizer/controller/organizer_follow_toggle_controller.dart';
import 'package:theme/theme.dart';

class OrganizerDetailScreen extends BaseStatefulWidget {
  final String id;
  final String name;
  final String? category;
  final String? logoUrl;
  final bool initiallySubscribed;

  const OrganizerDetailScreen({
    super.key,
    required this.id,
    required this.name,
    this.category,
    this.logoUrl,
    this.initiallySubscribed = false,
  });

  @override
  String get screenName => 'organizer_detail_screen';

  @override
  ConsumerState<OrganizerDetailScreen> createState() =>
      _OrganizerDetailScreenState();
}

class _OrganizerDetailScreenState
    extends BaseStatefulWidgetState<OrganizerDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref
          .read(organizerDetailControllerProvider(widget.id).notifier)
          .fetchDetail(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200.h) {
      ref
          .read(organizerDetailControllerProvider(widget.id).notifier)
          .loadMoreEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerDetailControllerProvider(widget.id));
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final detail = state.detail;
    final isSubscribed = detail?.isFollowing ?? widget.initiallySubscribed;
    final displayName = detail?.displayName ?? detail?.username ?? widget.name;
    final displayCategory = detail?.summary ?? widget.category;
    final displayLogoUrl = detail?.avatar ?? widget.logoUrl;
    final initials = nameInitials(displayName);
    final events = detail?.upcomingEvents ?? [];
    final eventsTotal = detail?.upcomingEventsTotal ?? events.length;

    return Scaffold(
      backgroundColor: context.templateColors.bgColor,
      appBar: OrganizerDetailsAppbar(id: widget.id),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (state.stateConstant == StateConstant.loading)
              SliverToBoxAdapter(child: TemplateCLoader(height: 300.h))
            else ...[
              SliverToBoxAdapter(
                child: _OrganizerHeaderCard(
                  name: displayName,
                  category: displayCategory,
                  logoUrl: displayLogoUrl,
                  initials: initials,
                  isSubscribed: isSubscribed,
                  onSubscribeTap: () {
                    if (isSubscribed) {
                      showOrganizerUnsubscribeSheet(
                        context,
                        name: displayName,
                        category: displayCategory,
                        logoUrl: displayLogoUrl,
                        onConfirmUnsubscribe: () => ref
                            .read(organizerToggleControllerProvider)
                            .toggle(widget.id, subscribe: false),
                      );
                    } else {
                      ref
                          .read(organizerToggleControllerProvider)
                          .toggle(widget.id, subscribe: true);
                    }
                  },
                ),
              ),

              // Description
              if (detail?.summary?.isNotEmpty == true)
                SliverToBoxAdapter(
                  child: _buildOrganizerDescription(
                    description: detail?.summary,
                    isDarkMode: isDarkMode,
                  ),
                ),

              // Action buttons (Subscribe + Homepage + Event count)
              SliverToBoxAdapter(
                child: _ActionButtonsRow(
                  isSubscribed: isSubscribed,
                  onSubscribeTap: () {
                    if (isSubscribed) {
                      showOrganizerUnsubscribeSheet(
                        context,
                        name: displayName,
                        category: displayCategory,
                        logoUrl: displayLogoUrl,
                        onConfirmUnsubscribe: () => ref
                            .read(organizerToggleControllerProvider)
                            .toggle(widget.id, subscribe: false),
                      );
                    } else {
                      ref
                          .read(organizerToggleControllerProvider)
                          .toggle(widget.id, subscribe: true);
                    }
                  },
                  eventCount: eventsTotal,
                  websiteUrl: detail?.website,
                  onHomepageTap: detail?.website?.isNotEmpty == true
                      ? () => ref
                            .read(launcherHandler)
                            .executeAction(context, detail?.website ?? '')
                      : null,
                ),
              ),

              // Address fact card
              if (detail?.address?.isNotEmpty == true)
                SliverToBoxAdapter(
                  child: _InfoFactCard(
                    label: 'organizer_detail_address'.tr,
                    value: detail?.address ?? '',
                  ),
                ),

              // Carousel — after fact cards, before events; no date badge or favourite button
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 16.h),
              //     child: ListingImageCarousel(
              //       imageUrls: displayLogoUrl != null && displayLogoUrl.isNotEmpty
              //           ? [displayLogoUrl]
              //           : [],
              //       day: '',
              //       month: '',
              //       height: 361,
              //       borderRadius: 20,
              //       badgeBorderRadius: 8,
              //       showDateBadge: false,
              //       showFavoriteButton: false,
              //     ),
              //   ),
              // ),

              // Events section
              if (events.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _EventsSectionHeader(count: eventsTotal),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: ListingItemCard.compact(
                        model: events[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(
                              listingId: events[index].id ?? '',
                            ),
                          ),
                        ),
                      ),
                    ),
                    childCount: events.length,
                  ),
                ),
                if (state.isLoadingMoreEvents)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ],

            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 32.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ORGANIZER HEADER CARD

class _OrganizerHeaderCard extends StatelessWidget {
  final String name;
  final String? category;
  final String? logoUrl;
  final String initials;
  final bool isSubscribed;
  final VoidCallback onSubscribeTap;

  const _OrganizerHeaderCard({
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.initials,
    required this.isSubscribed,
    required this.onSubscribeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final chipBg = context.templateColors.chipBg;
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final displayInitials = initials.isNotEmpty
        ? initials
        : name[0].toUpperCase();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dividerColor, width: 1.w),
              ),
              child: ClipOval(
                child: hasLogo
                    ? CommonImage(
                        imagePath: logoUrl!,
                        fit: BoxFit.cover,
                        width: 64.w,
                        height: 64.w,
                      )
                    : ColoredBox(
                        color: chipBg,
                        child: Center(
                          child: CommonText(
                            titleText: displayInitials,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 18.w),
            // Name + Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    titleText: name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                      height: 1.2,
                    ),
                  ),
                  if (category != null && category!.isNotEmpty) ...[
                    CommonText(
                      titleText: category!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: TemplateCColors.subHeadingGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ORGANIZER DESCRIPTION

Widget _buildOrganizerDescription({
  String? description,
  required bool isDarkMode,
}) {
  return Column(
    children: [
      CommonText(
        titleText: description ?? '',
        overflow: TextOverflow.clip,
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: isDarkMode
              ? TemplateCColors.textDescriptionLight
              : TemplateCColors.textDescriptionDark,
        ),
      ),
      SizedBox(height: 24.h),
    ],
  );
}

// ACTION BUTTONS ROW  (Subscribe + Homepage + Event count)

class _ActionButtonsRow extends StatelessWidget {
  final bool isSubscribed;
  final VoidCallback onSubscribeTap;
  final int eventCount;
  final String? websiteUrl;
  final VoidCallback? onHomepageTap;

  const _ActionButtonsRow({
    required this.isSubscribed,
    required this.onSubscribeTap,
    required this.eventCount,
    this.websiteUrl,
    this.onHomepageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final chipBg = context.templateColors.chipBg;
    final textColor = theme.extension<AppTextColors>()!.normal;
    final activeColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Row(
          children: [
            // Subscribe button
            GestureDetector(
              onTap: onSubscribeTap,
              child: Container(
                height: 46.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSubscribed ? chipBg : activeColor,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: isSubscribed ? dividerColor : activeColor,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      isSubscribed
                          ? 'assets/svg/subscribe_icon.svg'
                          : 'assets/svg/organizer_icon.svg',
                      width: 15.w,
                      height: 15.w,
                      colorFilter: ColorFilter.mode(
                        isSubscribed ? textColor : Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CommonText(
                      titleText: isSubscribed
                          ? 'organizer_subscribed'.tr
                          : 'listing_detail_organizer_subscribe'.tr,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        height: 1.2,
                        letterSpacing: 0,
                        color: isSubscribed ? null : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Homepage button — visible only when website is available
            if (websiteUrl != null && websiteUrl!.isNotEmpty)
              GestureDetector(
                onTap: onHomepageTap,
                child: Container(
                  height: 46.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: dividerColor, width: 1.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/link_icon.svg',
                        width: 15.w,
                        height: 15.w,
                        colorFilter: ColorFilter.mode(
                          textColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CommonText(
                        titleText: 'organizer_detail_homepage'.tr,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Event count
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    titleText: '$eventCount',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                      height: 1.0,
                      letterSpacing: 17 * 0.01,
                    ),
                  ),
                  CommonText(
                    titleText: 'organizer_detail_events_label'.tr,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 1.0,
                      letterSpacing: 14 * 0.02,
                      color: TemplateCColors.subHeadingGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// INFO FACT CARD  (address)

class _InfoFactCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoFactCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.templateColors.surfaceBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dividerColor, width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  titleText: label,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.0,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                SizedBox(height: 4.h),
                CommonText(
                  titleText: value,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.0,
                    letterSpacing: 14 * 0.02,
                    color: TemplateCColors.subHeadingGrey,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            isDark
                ? 'assets/svg/right_arrow_circular_light.svg'
                : 'assets/svg/right_arrow_circular_dark.svg',
            width: 25.w,
            height: 25.w,
          ),
        ],
      ),
    );
  }
}

// EVENTS SECTION HEADER

class _EventsSectionHeader extends StatelessWidget {
  final int count;

  const _EventsSectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        CommonText(
          titleText: 'organizer_detail_upcoming_events'.tr,
          textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            CommonText(
              titleText: '$count ${'organizer_detail_events_further'.tr}',
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.2,
                letterSpacing: 0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? TemplateCColors.textDescriptionLight
                    : TemplateCColors.textDescriptionDark,
              ),
            ),
            SizedBox(width: 4.w),
            CommonText(
              titleText: 'organizer_detail_events_name'.tr,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.2,
                letterSpacing: 0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? TemplateCColors.textDescriptionLight
                    : TemplateCColors.textDescriptionDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
