import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constant/common_enums.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../router/route_constant.dart';

class HeadlineBannerWidget extends BaseStatelessWidget {
  const HeadlineBannerWidget({
    super.key,
    this.onActionTap,
    this.fallbackHeight = 0,
  });

  final VoidCallback? onActionTap;

  /// Height returned when the banner is hidden (e.g. logged-in user).
  /// Pass a value to maintain consistent spacing in the parent layout.
  final double fallbackHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest =
        ref
            .read(preferenceManagerProvider)
            .getStringOrEmpty(StorageKeys.authRole) ==
        UserRole.guest.value;

    final isVisible =
        !(ref.watch(homeControllerProvider).isConfigLoading) && isGuest;

    if (!isVisible) {
      return SizedBox(height: fallbackHeight);
    }

    return GestureDetector(
      onTap: () {
        context.goNamed(RouteConstant.onboarding.name);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
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
                spacing: 20.h,
                children: [
                  // Tag row (right-aligned)
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
                      child: Text(
                        'banner_tag'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'banner_description_prefix'.tr),
                        TextSpan(
                          text: 'banner_description_highlight1'.tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        TextSpan(text: 'banner_description_middle'.tr),
                        TextSpan(
                          text: 'banner_description_highlight2'.tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'banner_action'.tr,
                        style: TextStyle(
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
            // Decorative SVG (top-left, partially outside)
            Positioned(
              left: 22.w,
              top: -32.h,
              child: BadgeIconWidget(foregroundIconPath: 'assets/icons/headline_decoration_icon.svg',),
            ),
          ],
        ),
      ),
    );
  }
}
