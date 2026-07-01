import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/listing/controller/listing_detail_controller.dart';

class DetailFactsRow extends BaseStatelessWidget {
  final ({String id, String familyKey}) providerKey;

  const DetailFactsRow({super.key, required this.providerKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref
        .watch(listingDetailControllerProvider(providerKey))
        .listing;

    final dateLine = formatEventDateFull(listing?.eventStart);
    final endDateLine = formatEventDateFull(listing?.eventEnd);
    final fullDateLine = (endDateLine.isNotEmpty && endDateLine != dateLine)
        ? '$dateLine\n$endDateLine'
        : dateLine;
    final timeLine = formatEventTime(listing?.eventStart, listing?.eventEnd);
    final hasDate = dateLine.isNotEmpty;

    final address = listing?.address?.isNotEmpty == true
        ? listing!.address!
        : null;
    final venueName = listing?.venueName?.isNotEmpty == true
        ? listing!.venueName!
        : null;
    final locationPrimary = venueName ?? address;
    final locationSecondary = venueName != null ? address : null;
    final hasLocation = locationPrimary != null;

    final websiteUrl = listing?.website?.isNotEmpty == true
        ? listing!.website!
        : null;

    final isFree = listing?.isFreeEntry == true;
    final priceTag = listing?.priceTag;
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
                await addEventToDeviceCalendarFromStrings(
                  context: context,
                  eventId: listing?.id ?? '',
                  title: listing?.title ?? '',
                  eventStart: listing?.eventStart?.toUtc().toIso8601String(),
                  eventEnd: listing?.eventEnd?.toUtc().toIso8601String(),
                  location: address ?? '',
                );
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
              onTap: () =>
                  ref.read(launcherHandler).executeAction(context, websiteUrl),
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
