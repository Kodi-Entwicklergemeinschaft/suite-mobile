import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/actions/app_bar_actions.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/widgets/app_bar_profile_pill.dart';
import 'package:theme/theme.dart';
import 'package:go_router/go_router.dart';

class HomeAppBar extends BaseStatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.locationLabel = 'Ortsauswahl',
    this.profileInitials = 'TH',
    this.onLocationTap,
    this.onProfileTap,
  });

  final String locationLabel;
  final String profileInitials;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invertedColor = Theme.of(context).extension<AppTextColors>()!.normal;
    final pref = ref.watch(preferenceManagerProvider);
    final savedLocation = pref.getStringOrNull(StorageKeys.selectedLocation);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 18.w,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: onLocationTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CommonText(
                titleText:
                    savedLocation?.split(',').first ?? "select_location".tr,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              'assets/icons/chevron_down.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(invertedColor, BlendMode.srcIn),
            ),
          ],
        ),
      ),
      actions: [
        if (AppBarActions.isPoiIncluded) ...[
          GestureDetector(
            onTap: (){
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
        SizedBox(width: 18.w),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1),
      ),
    );
  }
}
