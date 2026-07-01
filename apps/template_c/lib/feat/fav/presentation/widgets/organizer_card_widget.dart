import 'package:common_components/common_components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class OrganizerCardWidget extends StatelessWidget {
  final String name;
  final String? category;
  final String? logoUrl;
  final bool isSubscribed;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onTap;

  const OrganizerCardWidget({
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
    final bgColor = context.templateColors.surfaceBg;
    final chipBg = context.templateColors.chipBg;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      width: 199.w,
      padding: EdgeInsets.fromLTRB(12.w, 24.h, 12.w, 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 54,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo circle
          _OrganizerCardLogo(
            name: name,
            logoUrl: logoUrl,
            dividerColor: dividerColor,
            chipBg: chipBg,
          ),
          SizedBox(height: 20.h),
          // Name + Category
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText(
                titleText: name,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 1.2,
                  letterSpacing: 14 * 0.02,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (category != null && category!.isNotEmpty) ...[
                SizedBox(height: 4.h),
                CommonText(
                  titleText: category!,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.2,
                    letterSpacing: 12 * 0.02,
                    color: const Color(0xFFBABCC5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          SizedBox(height: 20.h),
          // Toggle + Label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoSwitch(
                value: isSubscribed,
                onChanged: (_) => onSubscribeTap?.call(),
                activeTrackColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 8.h),
              CommonText(
                titleText: isSubscribed
                    ? 'organizer_subscribed'.tr
                    : 'listing_detail_organizer_subscribe'.tr,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 1.0,
                  letterSpacing: 14 * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _OrganizerCardLogo extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final Color dividerColor;
  final Color chipBg;

  const _OrganizerCardLogo({
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
        border: Border.all(color: dividerColor, width: 0.89),
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
