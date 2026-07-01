import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/template_chip.dart';

// ── Figma: node 258-5900 "Home Tabs" ─────────────────────────────────────────

enum HomeTab { heute, morgen, dieseWoche, customDate }

class HomeTabBarWidget extends StatelessWidget {
  final HomeTab? activeTab;
  final ValueChanged<HomeTab> onTabSelected;
  final VoidCallback? onDatepickerTap;
  final bool isDatepickerActive;

  const HomeTabBarWidget({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.onDatepickerTap,
    this.isDatepickerActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DatepickerButton(onTap: onDatepickerTap, isActive: isDatepickerActive),
            SizedBox(width: 10.0.w),
            TemplateChip(
              label: 'home_tab_today'.tr,
              isActive: activeTab != null && activeTab == HomeTab.heute,
              onTap: () => onTabSelected(HomeTab.heute),
            ),
            SizedBox(width: 10.0.w),
            TemplateChip(
              label: 'home_tab_tomorrow'.tr,
              isActive: activeTab != null && activeTab == HomeTab.morgen,
              onTap: () => onTabSelected(HomeTab.morgen),
            ),
            SizedBox(width: 10.0.w),
            TemplateChip(
              label: 'home_tab_this_week'.tr,
              isActive: activeTab != null && activeTab == HomeTab.dieseWoche,
              onTap: () => onTabSelected(HomeTab.dieseWoche),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatepickerButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;

  const _DatepickerButton({this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.0.w,
        height: 42.0.h,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.secondary
              : context.templateColors.chipBg,
          borderRadius: BorderRadius.circular(45.5.r),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1.0,
          ),
        ),
        child: SvgPicture.asset(
        'assets/icons/datepicker_icon.svg',
        colorFilter: ColorFilter.mode(
          isActive
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          BlendMode.srcIn,
        ),
                ),
      ),
    );
  }
}
