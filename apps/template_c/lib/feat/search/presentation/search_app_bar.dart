import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/actions/app_bar_actions.dart';
import 'package:template_c/core/widgets/app_bar_profile_pill.dart';
import 'package:go_router/go_router.dart';

class SearchAppBar extends BaseStatelessWidget {
  const SearchAppBar({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding),
        SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                CommonText(
                  titleText: 'search_title'.tr,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                ),
                const Spacer(),
                if (AppBarActions.isPoiIncluded) ...[
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(AppBarActions.poiRoute);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/search_icon.svg',
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                AppBarProfilePill(onTap: onProfileTap),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
