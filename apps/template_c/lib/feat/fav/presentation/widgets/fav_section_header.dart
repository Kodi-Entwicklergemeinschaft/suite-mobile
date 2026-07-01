import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

class FavSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onFilterTap;

  const FavSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 44.h,
        bottom: 24.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  titleText: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  4.verticalSpace,
                  CommonText(
                    titleText: subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: CommonImage(
                imagePath: 'assets/svg/fav_filter.svg',
                color: Theme.of(context).extension<AppTextColors>()?.normal,
              ),
            ),
        ],
      ),
    );
  }
}
