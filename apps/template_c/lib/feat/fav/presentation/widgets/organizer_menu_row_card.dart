import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:theme/theme.dart';

class OrganizerMenuRowCard extends StatelessWidget {
  final String name;
  final String? category;
  final String? logoUrl;
  final bool isSubscribed;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onTap;

  const OrganizerMenuRowCard({
    super.key,
    required this.name,
    this.category,
    this.logoUrl,
    this.isSubscribed = false,
    this.onSubscribeTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final textColors = Theme.of(context).extension<AppTextColors>()!.normal;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 100.h,
        child: Row(
          children: [
            _Logo(
              name: name,
              logoUrl: logoUrl,
              dividerColor: dividerColor,
              chipBg: context.templateColors.chipBg,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    titleText: name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      height: 1.2,
                      letterSpacing: 0.01,
                    ),
                  ),
                  if (category != null && category!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    CommonText(
                      titleText: category!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: TemplateCColors.subHeadingGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _SubscribeButton(
              isSubscribed: isSubscribed,
              onTap: onSubscribeTap,
              dividerColor: dividerColor,
              theme: theme,
              chipBg: context.templateColors.chipBg,
              textColor: textColors
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final Color dividerColor;
  final Color chipBg;

  const _Logo({
    required this.name,
    required this.logoUrl,
    required this.dividerColor,
    required this.chipBg,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return Container(
      width: 64.w,
      height: 64.w,
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
                    titleText: name.isNotEmpty ? name[0].toUpperCase() : '-',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final bool isSubscribed;
  final VoidCallback? onTap;
  final Color dividerColor;
  final ThemeData theme;
  final Color chipBg;
  final Color textColor;

  const _SubscribeButton({
    required this.isSubscribed,
    required this.onTap,
    required this.dividerColor,
    required this.theme,
    required this.chipBg,
    required this.textColor
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSubscribed ? chipBg : activeColor,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSubscribed ? dividerColor : activeColor,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              isSubscribed ? 'assets/svg/subscribe_icon.svg' : 'assets/svg/organizer_icon.svg',
              width: 15.w,
              height: 15.w,
              colorFilter: ColorFilter.mode(
                isSubscribed ? textColor : Colors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 6.w),
            CommonText(
              titleText: isSubscribed ? 'organizer_subscribed'.tr : 'listing_detail_organizer_subscribe'.tr,
              textStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 0,
                color: isSubscribed ? null : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
