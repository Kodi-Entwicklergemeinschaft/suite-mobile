import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/date_badge.dart';
import 'package:template_c/core/widgets/favorite_button.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/home/widgets/listing/listing_card_shells.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/ui/widgets/listing_image_carousel.dart';
import 'package:template_c/offline/fav_offline/controller/fav_offline_controller.dart';

enum ListingCardVariant { standard, subcategory, moreDates, highlight, compact }

class ListingItemCard extends BaseStatelessWidget {
  final ListingModel model;
  final String familyKey;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final ListingCardVariant _variant;

  const ListingItemCard({
    super.key,
    required this.model,
    this.familyKey = '',
    this.onTap,
    this.onFavoriteTap,
  }) : _variant = ListingCardVariant.standard;

  const ListingItemCard.highlight({
    super.key,
    required this.model,
    this.familyKey = '',
    this.onTap,
  }) : onFavoriteTap = null,
       _variant = ListingCardVariant.highlight;

  const ListingItemCard.subcategory({
    super.key,
    required this.model,
    this.onTap,
  }) : familyKey = '',
       onFavoriteTap = null,
       _variant = ListingCardVariant.subcategory;

  const ListingItemCard.moreDates({super.key, required this.model, this.onTap})
    : familyKey = '',
      onFavoriteTap = null,
      _variant = ListingCardVariant.moreDates;

  const ListingItemCard.compact({super.key, required this.model, this.onTap})
    : familyKey = '',
      onFavoriteTap = null,
      _variant = ListingCardVariant.compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = familyKey.isNotEmpty
        ? ref.read(listingControllerProvider(familyKey).notifier)
        : null;

    void onFavTap() {
      if (onFavoriteTap != null) {
        onFavoriteTap!();
        return;
      }
      if (controller == null || model.id == null) return;
      if (model.isFavorite == true) {
        controller.removeFav(id: model.id!);
        ref
            .read(favOfflineControllerProvider.notifier)
            .removeFavItem(model.id!);
      } else {
        controller.addFav(id: model.id!);
        final res = model.copyWith(isFavorite: true);
        ref.read(favOfflineControllerProvider.notifier).addFavItem(res);
      }
    }

    if (_variant == ListingCardVariant.subcategory) {
      return _CompactCard(model: model, onTap: onTap);
    }
    if (_variant == ListingCardVariant.moreDates) {
      return _CompactVerticalCard(model: model, onTap: onTap);
    }
    if (_variant == ListingCardVariant.highlight) {
      return _HighlightCard(model: model, onTap: onTap, onFavTap: onFavTap);
    }
    if (_variant == ListingCardVariant.compact) {
      return _SearchCard(model: model, onTap: onTap);
    }

    final badgeDate = resolvedBadgeDate(model);
    final imageUrls = model.resolvedImageUrl != null
        ? [model.resolvedImageUrl!]
        : <String>[];

    return StandardCardShell(
      onTap: onTap,
      imageWidget: ListingImageCarousel(
        imageUrls: imageUrls,
        categoryFallbackImage: model.imageFallback,
        day: badgeDate?.day.toString() ?? '',
        month: badgeDate != null ? monthAbbr(badgeDate.month) : '',
        isFavorite: model.isFavorite ?? false,
        height: 272,
        borderRadius: 8,
        badgeBorderRadius: 4,
        onFavoriteTap: onFavTap,
      ),
      infoSection: _CardInfoSection(model: model),
    );
  }
}

// ============================================================================
// COMPACT CARD — same design as the old SubcategoryCard
// ============================================================================

class _CompactCard extends StatelessWidget {
  final ListingModel model;
  final VoidCallback? onTap;

  const _CompactCard({required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = model.title ?? '';
    final dateRange = getDateRange(model) ?? '';
    final timeText = formatEventTime(model.eventStart, model.eventEnd);
    final actionLabel = model.address ?? '';

    return CompactCardShell(
      onTap: onTap,
      imageWidget: model.resolvedImageUrl != null
          ? buildListingImage(model, width: 96.w, height: 96.h)
          : Container(color: Theme.of(context).colorScheme.surfaceContainer),
      contentColumn: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardTitleText(title),
              SizedBox(height: 4.h),
              if (dateRange.isNotEmpty) ...[
                CardSubtitleText(dateRange, maxLines: 1),
              ],
              if (timeText.isNotEmpty) ...[
                SizedBox(height: 2.h),
                CardSubtitleText(timeText, maxLines: 1),
              ],
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (actionLabel.isNotEmpty)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/map_pin_icon.svg',
                        width: 12.w,
                        height: 12.h,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: CommonText(
                          titleText: actionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                            letterSpacing: 0.26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (formatBisDate(model.eventEnd).isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.4.w,
                    vertical: 3.1.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerTheme.color?.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(21.r),
                  ),
                  child: CommonText(
                    titleText: formatBisDate(model.eventEnd),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPACT VERTICAL CARD — date, time, price pill (no title, no venue)
// ============================================================================

class _CompactVerticalCard extends StatelessWidget {
  final ListingModel model;
  final VoidCallback? onTap;

  const _CompactVerticalCard({required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateLine = getDateRange(model) ?? '';
    final timeLine = formatEventTime(model.eventStart, model.eventEnd);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: context.templateColors.surfaceBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              offset: Offset(0, 8.h),
              blurRadius: 54.r,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Square image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  width: 96.w,
                  height: 96.h,
                  child: model.resolvedImageUrl != null
                      ? buildListingImage(model, width: 96.w, height: 96.h)
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date + time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          titleText: dateLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            letterSpacing: 0.28,
                          ),
                        ),
                        if (timeLine.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          CommonText(
                            titleText: timeLine,
                            maxLines: 1,
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
                    _PriceWidget(model: model),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED PRICE WIDGET
// ============================================================================

class _PriceWidget extends StatelessWidget {
  final ListingModel model;

  const _PriceWidget({required this.model});

  @override
  Widget build(BuildContext context) {
    // if (model.isFreeEntry == true) {
    //   return CommonText(
    //     titleText: 'listing_detail_facts_free'.tr,
    //     textStyle: TextStyle(
    //       fontWeight: FontWeight.w700,
    //       fontSize: 13.sp,
    //       color: Theme.of(context).colorScheme.primary,
    //     ),
    //   );
    // }
    if (model.priceTag != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/price_tag.svg',
            width: 13.w,
            height: 13.h,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 3.w),
          CommonText(
            titleText: '${model.priceTag} €',
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              letterSpacing: 0.28,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ============================================================================
// STANDARD CARD INFO SECTION
// ============================================================================

class _CardInfoSection extends StatelessWidget {
  final ListingModel model;

  const _CardInfoSection({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CommonText(
                  titleText: model.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                    letterSpacing: 0.34,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _PriceWidget(model: model),
            ],
          ),
          if (getDateRange(model) != null) ...[
            SizedBox(height: 6.h),
            CommonText(
              titleText: getDateRange(model)!,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0.28,
                color: TemplateCColors.subHeadingGrey,
              ),
            ),
          ],
          if (formatEventTime(model.eventStart, model.eventEnd).isNotEmpty) ...[
            SizedBox(height: 2.h),
            CommonText(
              titleText: formatEventTime(model.eventStart, model.eventEnd),
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                letterSpacing: 0.26,
                color: TemplateCColors.subHeadingGrey,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          if (model.address?.isNotEmpty == true)
            CommonText(
              titleText: model.address ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0.28,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEARCH CARD — image left, title + price right, date in primary, venue·address
// ============================================================================

class _SearchCard extends StatelessWidget {
  final ListingModel model;
  final VoidCallback? onTap;

  const _SearchCard({required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = model.title ?? '';
    final dateText = getDateRange(model) ?? '';
    final timeText = formatEventTime(model.eventStart, model.eventEnd);

    final locationText = model.address ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.templateColors.surfaceBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              offset: Offset(0, 8.h),
              blurRadius: 54.r,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Square image
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 110.w,
                  height: 110.w,
                  child: model.resolvedImageUrl != null
                      ? buildListingImage(model, width: 110.w, height: 110.w)
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row + price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CommonText(
                            titleText: title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _PriceWidget(model: model),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Date range — primary color
                    if (dateText.isNotEmpty)
                      CommonText(
                        titleText: dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          letterSpacing: 0.26,
                          color: TemplateCColors.subHeadingGrey,
                        ),
                      ),
                    // Time — below date
                    if (timeText.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      CommonText(
                        titleText: timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          letterSpacing: 0.26,
                          color: TemplateCColors.subHeadingGrey,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    // Venue · Address
                    if (locationText.isNotEmpty)
                      CommonText(
                        titleText: locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                          letterSpacing: 0.26,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HIGHLIGHT CARD
// ============================================================================

class _HighlightCard extends StatelessWidget {
  final ListingModel model;
  final VoidCallback? onTap;
  final VoidCallback? onFavTap;

  const _HighlightCard({required this.model, this.onTap, this.onFavTap});

  @override
  Widget build(BuildContext context) {
    final badgeDate = resolvedBadgeDate(model);
    final date = badgeDate?.day.toString() ?? '';
    final month = badgeDate != null ? monthAbbr(badgeDate.month) : '';

    return Container(
      width: 296.w,
      height: 400.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color!,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            offset: Offset(0, 8.h),
            blurRadius: 54.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onTap,
                child: buildListingImage(model),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xCC000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: GestureDetector(
                onTap: onTap,
                child: DateBadge(date: date, month: month),
              ),
            ),

            Positioned(
              top: 247.h,
              left: 0.5.w,
              right: 0.5.w,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: CommonText(
                        titleText: 'highlight_chip_label'.tr,
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: TemplateCColors.lightModeBackground,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    CommonText(
                      titleText: (model.title ?? '').toUpperCase(),
                      textAlign: TextAlign.center,
                      textStyle: context
                          .templateColors
                          .secondaryTextTheme
                          ?.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 42.sp,
                            height: 1,
                            color: TemplateCColors.lightModeBackground,
                            letterSpacing: 0.84,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    CommonText(
                      titleText: model.summary ?? '',
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TemplateCColors.lightModeBackground,
                        fontSize: 17.sp,
                        letterSpacing: 0.34,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 12.h,
              right: 12.w,
              child: FavoriteButton(
                isFavorite: model.isFavorite ?? false,
                onTap: onFavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
