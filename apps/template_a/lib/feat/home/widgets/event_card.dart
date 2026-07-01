import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';


class EventCard extends StatelessWidget {
  final String imageUrl;
  final String? fallbackImageUrl;
  final String dateRange;
  final String title;
  final bool isFavourite;
  final Color bgColor;
  final VoidCallback? onTap;
  final VoidCallback? onTapOnFavourite;

  const EventCard({
    super.key,
    required this.imageUrl,
    this.fallbackImageUrl,
    required this.dateRange,
    required this.title,
    this.isFavourite = false,
    required this.bgColor,
    this.onTap,
    this.onTapOnFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 12.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: bgColor,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onTap != null,
        label: title,
        child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 160.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl.isNotEmpty)
                _EventImage(
                  imageUrl: imageUrl,
                  fallbackImageUrl: fallbackImageUrl,
                  isFavourite: isFavourite,
                  onTapOnFavourite: onTapOnFavourite,
                  fallbackColor: bgColor,
                ),
              _EventDetails(
                dateRange: dateRange,
                title: title,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackImageUrl;
  final bool isFavourite;
  final VoidCallback? onTapOnFavourite;
  final Color fallbackColor;

  const _EventImage({
    required this.imageUrl,
    this.fallbackImageUrl,
    required this.isFavourite,
    this.onTapOnFavourite,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isNotEmpty
              ? CommonImage(
                  imagePath: imageUrl,
                  fit: BoxFit.cover,
                  cacheHeight:
                      (90 * MediaQuery.of(context).devicePixelRatio).round(),
                  cacheWidth:
                      (160 * MediaQuery.of(context).devicePixelRatio).round(),
                  errorWidget: fallbackImageUrl?.isNotEmpty == true
                      ? (context, error, stack) => CommonImage(
                            imagePath: fallbackImageUrl!,
                            fit: BoxFit.cover,
                          )
                      : null,
                )
              : Container(
                  color: fallbackColor.withValues(alpha: 0.3),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 30.sp,
                      color: Colors.white30,
                    ),
                  ),
                ),
          if (onTapOnFavourite != null)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: _FavoriteButton(
                isFavourite: isFavourite,
                onTap: onTapOnFavourite!,
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavourite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          color: isFavourite ? Colors.red : Colors.white,
        ),
        iconSize: 24.h,
        splashRadius: 24.h,
        padding: EdgeInsets.all(10.h),
        constraints: BoxConstraints(minWidth: 44.h, minHeight: 44.h),
        tooltip: isFavourite ? 'remove_from_favourites'.tr : 'add_to_favourites'.tr,
      ),
    );
  }
}

class _EventDetails extends StatelessWidget {
  final String dateRange;
  final String title;

  const _EventDetails({
    required this.dateRange,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const primaryColor = Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: dateRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          CommonText(
            titleText: title,
            maxLines: 2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            textStyle: textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
