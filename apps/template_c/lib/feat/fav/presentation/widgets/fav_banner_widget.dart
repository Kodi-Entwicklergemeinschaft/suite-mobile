import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavBannerWidget extends StatelessWidget {
  const FavBannerWidget({
    super.key,
    required this.badge,
    required this.tag,
    required this.descriptionHighlight,
    this.descriptionMiddle,
    this.descriptionHighlight2,
    required this.descriptionSuffix,
    required this.actionText,
    this.onActionTap,
  });

  /// Badge widget placed top-left, partially outside the card.
  /// Pass a pre-built widget (e.g. [CommonImage] or a styled [Container]).
  final Widget badge;

  final String tag;
  final String descriptionHighlight;
  final String? descriptionMiddle;
  final String? descriptionHighlight2;
  final String descriptionSuffix;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActionTap,
      child: Padding(
        padding: EdgeInsets.only(top: 48.h, bottom: 24.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tag pill (right-aligned)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.4.w,
                        vertical: 3.1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9999.r),
                      ),
                      child: CommonText(
                        titleText: tag,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Description with highlighted phrase(s)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: descriptionHighlight,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        if (descriptionMiddle != null)
                          TextSpan(
                            text: descriptionMiddle,
                            style: const TextStyle(color: Colors.white),
                          ),
                        if (descriptionHighlight2 != null)
                          TextSpan(
                            text: descriptionHighlight2,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        TextSpan(
                          text: descriptionSuffix,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Action row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonText(
                        titleText: actionText,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(
                        'assets/icons/arrow_icon.svg',
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge positioned top-left, partially outside the card
            Positioned(
              left: 16.w,
              top: -32.h,
              child: badge,
            ),
          ],
        ),
      ),
    );
  }
}
