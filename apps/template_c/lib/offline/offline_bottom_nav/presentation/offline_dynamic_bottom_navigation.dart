import 'dart:ui';
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/offline/offline_bottom_nav/controller/offline_bottom_nav_controller.dart';
import 'package:template_c/offline/offline_bottom_nav/presentation/offline_nav_item.dart';
import 'package:theme/theme.dart';

class OfflineDynamicBottomNavBar extends BaseStatelessWidget {
  final List<Widget> screenList;
  final List<OfflineNavItem> navItems;
  final int selectedIndex;

  const OfflineDynamicBottomNavBar({
    super.key,
    required this.screenList,
    required this.navItems,
    required this.selectedIndex,
  });

  Widget _buildIcon(OfflineNavItem item, Color color) {
    if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
      return CommonImage(
        imagePath: item.iconUrl!,
        height: 24.h,
        width: 24.h,
        color: color,
      );
    }
    return Icon(item.icon, size: 24.h, color: color);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(offlineBottomNavControllerProvider.notifier);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          height: MediaQuery.textScalerOf(context).scale(1.0) > 1.2
              ? 120.h
              : 90.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(255, 255, 255, 0.8)
                    : const Color.fromRGBO(35, 44, 57, 0.7),
                width: 1.h,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = index == selectedIndex;
              final color = isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).extension<AppTextColors>()!.normal;

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.updateSelectedIndex(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIcon(item, color),
                      4.verticalSpace,
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
