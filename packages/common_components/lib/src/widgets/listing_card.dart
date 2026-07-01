import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_image.dart';
import 'common_icon.dart';
import 'common_shimmer.dart';
import 'common_text.dart';

class ListingCard extends StatelessWidget {
  final String? imageUrl;
  final double? distance;
  final String name;
  final String? address;
  final String? todayOpeningStatus;
  final VoidCallback? onTap;
  final VoidCallback? onTapFavourite;
  final bool isFavourite;
  final Color? headerColor;
  final String? imageLabel;
  final String? searchedString;
  final int? nameMaxLine;
  final bool showFavourite;

  const ListingCard({
    super.key,
    this.imageUrl,
    this.distance,
    required this.name,
    this.address,
    this.todayOpeningStatus,
    this.onTap,
    this.onTapFavourite,
    this.isFavourite = false,
    this.headerColor,
    this.imageLabel,
    this.searchedString,
    this.nameMaxLine,
    this.showFavourite = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              SizedBox(width: 160.w, child: _buildImage(context, theme)),
              SizedBox(width: 10.w),
            ],
            Expanded(child: _buildDetails(context, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeData theme) {
    final baseColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7);
    final highlightColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: CommonImage(
        imagePath: imageUrl!,
        label: imageLabel ?? 'listing_image_label',
        fit: BoxFit.cover,
        height: 120.h,
        width: 160.w,
        loadingWidget: CommonShimmer(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 120.h,
            width: 160.w,
            color: theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Distance badge
        if (distance != null)
          Container(
            margin: EdgeInsets.only(bottom: 5.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: headerColor ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: CommonText(
              titleText: '${(distance! / 1000).toStringAsFixed(2)} km',
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Title + Heart icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HighlightText(
                source: name,
                query: searchedString,
                highlightColor: theme.colorScheme.secondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
            if (showFavourite)
              GestureDetector(
                onTap: onTapFavourite,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
                  child: CommonIcon(
                    icon: isFavourite ? Icons.favorite : Icons.favorite_border,
                    size: 22.r,
                    color: isFavourite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                    label: 'favourite_icon_label',
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 5.h),

        // Address
        if (address != null && address!.isNotEmpty)
          Row(
            children: [
              CommonIcon(
                icon: Icons.location_on,
                size: 14.r,
                color: theme.colorScheme.onSurfaceVariant,
                label: 'location',
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: CommonText(
                  titleText: address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: 5.h),

        // Date / opening hours
        if (todayOpeningStatus != null && todayOpeningStatus!.isNotEmpty)
          Row(
            children: [
              CommonIcon(
                icon: Icons.access_time_filled,
                size: 14.r,
                color: theme.colorScheme.onSurfaceVariant,
                label: 'time',
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: CommonText(
                  titleText: todayOpeningStatus!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: headerColor ?? theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
