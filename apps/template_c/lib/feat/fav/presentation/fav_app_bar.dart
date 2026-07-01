import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/widgets/app_bar_profile_pill.dart';
import 'package:template_c/router/feature_routes.dart';
import 'package:theme/theme.dart';


class FavSliverAppBar extends BaseStatelessWidget {
  const FavSliverAppBar({
    super.key,
    this.profileInitials = 'TH',
    this.onLocationTap,
    this.onSearchTap,
    this.onProfileTap,
  });

  final String profileInitials;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invertedColor = Theme.of(context).extension<AppTextColors>()!.normal;

    return SliverAppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      floating: false,
      snap: false,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 18.w,
      centerTitle: false,
      title: GestureDetector(
        onTap: onLocationTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CommonText(
                titleText: 'events'.tr,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(
              'assets/icons/chevron_down.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(invertedColor, BlendMode.srcIn),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        if (featureRoute.any((r) => r.name == 'poi')) ...[
          GestureDetector(
            onTap: onSearchTap,
            child: SvgPicture.asset(
              'assets/icons/search_icon.svg',
              width: 32.w,
              height: 32.h,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        AppBarProfilePill(onTap: onProfileTap),
        SizedBox(width: 18.w),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1),
      ),
    );
  }
}
