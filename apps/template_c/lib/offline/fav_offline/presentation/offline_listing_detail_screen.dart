import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/app_back_button.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_about_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_bottom_cta.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_map_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_organizer_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_title_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/listing_image_carousel.dart';

class OfflineListingDetailScreen extends BaseStatelessWidget {
  final ListingModel listing;
  final VoidCallback? onFavTap;

  const OfflineListingDetailScreen({
    super.key,
    required this.listing,
    this.onFavTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.templateColors.bgColor,
      appBar: _OfflineDetailAppBar(listing: listing),
      body: _OfflineDetailBody(listing: listing, onFavTap: onFavTap),
    );
  }
}

class _OfflineDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ListingModel listing;

  const _OfflineDetailAppBar({required this.listing});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 18.w,
      centerTitle: true,
      leadingWidth: 40.w,
      leading: const AppBackButton(),
      title: CommonText(
        titleText: 'listing_event'.tr,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => shareEvent(
            title: listing.title ?? '',
            dateLine: formatEventDateFull(listing.eventStart),
            address: listing.address,
            websiteUrl: listing.website,
          ),
          child: isDark
              ? SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_dark.svg',
                  width: 32.w,
                  height: 32.h,
                )
              : SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_light.svg',
                  width: 32.w,
                  height: 32.h,
                ),
        ),
        SizedBox(width: 18.w),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1),
      ),
    );
  }
}

class _OfflineDetailBody extends BaseStatelessWidget {
  final ListingModel listing;
  final VoidCallback? onFavTap;

  const _OfflineDetailBody({required this.listing, this.onFavTap});

  List<String> get _imageUrls {
    final seen = <String>{};
    final urls = <String>[];
    for (final url in [
      if (listing.heroImageUrl?.isNotEmpty == true) listing.heroImageUrl!,
      ...?listing.media
          ?.where((m) => m.type == 'image' && m.url?.isNotEmpty == true)
          .map((m) => m.url!),
    ]) {
      if (seen.add(url)) urls.add(url);
    }
    return urls;
  }

  bool get _hasMap => listing.geoLat != null && listing.geoLng != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventStart = listing.eventStart;

    final dayText = eventStart?.day.toString() ?? '';
    final monthText = eventStart != null ? monthAbbr(eventStart.month) : '';

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ── Carousel ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: ListingImageCarousel(
                  imageUrls: _imageUrls,
                  day: dayText,
                  month: monthText,
                  isFavorite: listing.isFavorite ?? false,
                  height: 361.h,
                  borderRadius: 20,
                  badgeBorderRadius: 8,
                  onFavoriteTap: onFavTap,
                ),
              ),
            ),

            // ── Title + tags ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: DetailTitleWidget(
                title: listing.title ?? '',
                subcategoryTitle: listing.subcategoryTitle,
              ),
            ),

            // ── Facts row ────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.only(bottom: 36.h),
              sliver: SliverToBoxAdapter(
                child: _OfflineFactsRow(listing: listing),
              ),
            ),

            // ── About — only if content present ─────────────────────────
            if (listing.content?.isNotEmpty == true) ...[
              SliverToBoxAdapter(
                child: DetailAboutWidget(content: listing.content),
              ),
              SliverToBoxAdapter(child: const _SectionDivider()),
            ],

            // ── Map — only if coordinates present ────────────────────────
            if (_hasMap)
              SliverPadding(
                padding: EdgeInsets.only(bottom: 60.h),
                sliver: SliverToBoxAdapter(
                  child: DetailMapWidget(
                    lat: listing.geoLat!,
                    lng: listing.geoLng!,
                    address: listing.address ?? '',
                  ),
                ),
              ),

            if (listing.organizer != null) ...[
              SliverToBoxAdapter(
                child: DetailOrganizerWidget(
                  organizer: listing.organizer!,
                  initiallySubscribed: listing.organizer!.isFollowing ?? false,
                  onOrganizerTap: () =>
                      AppSnackBar.showSuccess(context, 'no_internet'.tr),
                  onSubscribeChanged: (_) =>
                      AppSnackBar.showSuccess(context, 'no_internet'.tr),
                ),
              ),
              SliverToBoxAdapter(child: const _SectionDivider()),
            ],

            SliverToBoxAdapter(
              child: SizedBox(
                height: listing.registrationUrl?.isNotEmpty == true
                    ? 100.h
                    : 32.h,
              ),
            ),
          ],
        ),

        // ── Sticky bottom CTA — only if registrationUrl present ───────────
        if (listing.registrationUrl?.isNotEmpty == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DetailBottomCta(
              registrationUrl: listing.registrationUrl,
              onTap: () => ref
                  .read(launcherHandler)
                  .executeAction(context, listing.registrationUrl!),
            ),
          ),
      ],
    );
  }
}

class _OfflineFactsRow extends BaseStatelessWidget {
  final ListingModel listing;

  const _OfflineFactsRow({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLine = formatEventDateFull(listing.eventStart);
    final endDateLine = formatEventDateFull(listing.eventEnd);
    final fullDateLine = (endDateLine.isNotEmpty && endDateLine != dateLine)
        ? '$dateLine\n$endDateLine'
        : dateLine;
    final timeLine = formatEventTime(listing.eventStart, listing.eventEnd);
    final hasDate = dateLine.isNotEmpty;

    final address = listing.address?.isNotEmpty == true
        ? listing.address!
        : null;
    final venueName = listing.venueName?.isNotEmpty == true
        ? listing.venueName!
        : null;
    final locationPrimary = venueName ?? address;
    final locationSecondary = venueName != null ? address : null;
    final hasLocation = locationPrimary != null;

    final websiteUrl = listing.website?.isNotEmpty == true
        ? listing.website!
        : null;

    final isFree = listing.isFreeEntry;
    final priceTag = listing.priceTag;
    final priceValue = isFree
        ? 'listing_detail_facts_free'.tr
        : priceTag?.isNotEmpty == true
        ? priceTag
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          if (hasDate) ...[
            _FactCard(
              primary: fullDateLine,
              secondary: timeLine,
              suffixIconAsset: 'assets/svg/add.svg',
              onTap: () async {
                AppSnackBar.showSuccess(context, 'no_internet'.tr);
              },
            ),
            SizedBox(height: 8.h),
          ],
          if (hasLocation) ...[
            _FactCard(
              primary: locationPrimary!,
              secondary: locationSecondary ?? '',
              onTap: () {},
            ),
            SizedBox(height: 8.h),
          ],
          if (websiteUrl != null) ...[
            _FactCard(
              primary: 'listing_detail_facts_event_link'.tr,
              secondary: websiteUrl,
              secondaryMaxLines: 1,
              onTap: () => AppSnackBar.showSuccess(context, 'no_internet'.tr),
            ),
            SizedBox(height: 8.h),
          ],
          if (priceValue != null)
            _FactCard(
              primary: 'listing_detail_facts_admission'.tr,
              secondary: priceValue,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FACT CARD — same as the private _FactCard in detail_facts_row.dart
// ─────────────────────────────────────────────────────────────────────────────

class _FactCard extends StatelessWidget {
  final String primary;
  final String secondary;
  final int secondaryMaxLines;
  final VoidCallback? onTap;
  final String? suffixIconAsset;

  const _FactCard({
    required this.primary,
    required this.secondary,
    this.secondaryMaxLines = 2,
    this.onTap,
    this.suffixIconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.templateColors.surfaceBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerTheme.color!, width: 1.w),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    titleText: primary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      letterSpacing: 0.28,
                    ),
                  ),
                  if (secondary.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    CommonText(
                      titleText: secondary,
                      maxLines: secondaryMaxLines,
                      overflow: TextOverflow.ellipsis,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        letterSpacing: 0.28,
                        color: TemplateCColors.subHeadingGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 12.w),
              Container(
                width: 25.w,
                height: 25.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    suffixIconAsset ?? 'assets/icons/arrow_icon.svg',
                    width: 10.w,
                    height: 10.h,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.surface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 120.h,
      thickness: 8.h,
      color: Theme.of(context).dividerTheme.color,
    );
  }
}
