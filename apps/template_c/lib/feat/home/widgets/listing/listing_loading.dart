import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

// ============================================================================
// SHIMMER SKELETONS — one per variant, mirrors real card dimensions
// ============================================================================

Widget shimmerBox({
  required double width,
  required double height,
  double radius = 12,
}) {
  return CommonShimmer(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    ),
  );
}

/// V1 — horizontal list of full-card rectangles (matches HighlightCard 296w×400h)
class ListingShimmerV1 extends StatelessWidget {
  const ListingShimmerV1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) => shimmerBox(width: 296.w, height: 400.h, radius: 20),
      ),
    );
  }
}

/// V2 — image block + two text lines (matches ListingItemCard)
class ListingShimmerV2 extends StatelessWidget {
  const ListingShimmerV2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h + 16.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) => SizedBox(
          width: 296.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shimmerBox(width: 296.w, height: 272.h, radius: 8),
              SizedBox(height: 12.h),
              shimmerBox(width: 180.w, height: 16.h, radius: 6),
              SizedBox(height: 8.h),
              shimmerBox(width: 120.w, height: 14.h, radius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GENERIC STATUS WIDGET — empty / error states for all variants
// ============================================================================

class ListingStatusWidget extends StatelessWidget {
  final bool isEmpty;
  final bool isError;

  const ListingStatusWidget({
    super.key,
    this.isEmpty = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final message = isError ? 'listing_no_results'.tr : 'listing_no_data'.tr;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: CommonText(
          titleText: message,
          textStyle: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
