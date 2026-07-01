import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:theme/theme.dart';

class AppBarProfilePill extends BaseStatelessWidget {
  const AppBarProfilePill({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontDark = ref.watch(appThemeProvider).colors.fontDark;
    final data = ref.watch(profileControllerProvider).data;
    final firstName = data?.firstName?.trim() ?? '';
    final lastName = data?.lastName?.trim() ?? '';
    final username = data?.username?.trim() ?? '';
    final initials = (firstName.isNotEmpty && lastName.isNotEmpty)
        ? '${firstName[0]}${lastName[0]}'.toUpperCase()
        : username.isNotEmpty
            ? username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase()
            : 'GU';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.h,
        padding: EdgeInsets.only(left: 10.w, right: 3.4.w),
        decoration: BoxDecoration(
          color: TemplateCColors.darkModeCardBg,
          borderRadius: BorderRadius.circular(133.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(
              titleText:'profile'.tr,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 25.3.w,
              height: 25.3.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CommonText(
                titleText: initials,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 8.4.sp,
                  color: fontDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
