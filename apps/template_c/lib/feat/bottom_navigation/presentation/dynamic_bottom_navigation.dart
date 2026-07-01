import 'dart:ui'; // Required for ImageFilter
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_c/feat/bottom_navigation/model/bottom_nav_item_model.dart';
import 'package:theme/theme.dart';

class DynamicBottomNavBar extends BaseStatelessWidget {
  final List<Widget> screenList;
  final List<BottomNavItemModel> listOfNavItems;
  final int selectedIndex;

  DynamicBottomNavBar({
    required this.screenList,
    required this.listOfNavItems,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(bottomNavigationControllerProvider.notifier);
    final textScale = MediaQuery.textScalerOf(context);

    // 1. Wrap in ClipRect to contain the blur effect
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          height: textScale.scale(1.0) > 1.2 ? 120.h : 90.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? Color.fromRGBO(255, 255, 255, 0.8)
                    : Color.fromRGBO(35, 44, 57, 0.7),
                width: 1.h,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(screenList.length, (index) {
              final item = listOfNavItems[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.onNavItemTap(context, index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRect(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: CommonImage(
                              imagePath: item.iconUrl ?? '',
                              height: 24.h,
                              width: 24.w,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).extension<AppTextColors>()!.normal,
                            ),
                          ),
                        ),
                      ),
                      4.verticalSpace,
                      CommonText(
                        titleText: item.label ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
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
