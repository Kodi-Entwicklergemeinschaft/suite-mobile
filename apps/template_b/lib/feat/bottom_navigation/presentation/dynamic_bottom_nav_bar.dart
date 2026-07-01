import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/feat/bottom_navigation/model/ui_model/bottom_nav_bar_model.dart';
import 'package:theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicBottomNavBar extends BaseStatelessWidget {
  final BottomNavBarModel config;
  final Function(int)? onNavItemTapped;
  final int currentIndex;

  const DynamicBottomNavBar({
    super.key,
    required this.config,
    this.onNavItemTapped,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      height: textScale.scale(1.0) > 1.2 ? 120.h : 90.h,
      padding: EdgeInsets.only(
        top: 12.h,
        left: 24.w,
        bottom: 12.h,
        right: 24.w,
      ),
      decoration: BoxDecoration(
        color: Brightness.light == theme.brightness
            ? Color(0xFFD0D0D0)
            : Color(0xFF636363),

        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.scrim.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: _buildNavBarWithoutFab(config.items, context, ref, textScale),
    );
  }

  Widget _buildNavBarWithoutFab(
    List<NavItemModel> items,
    BuildContext context,
    WidgetRef ref,
    TextScaler textScale,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isSelected = currentIndex == index;
        Color? color = isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
        return Expanded(
          child: Semantics(
            button: true,
            label: item.label,
            selected: isSelected,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  onNavItemTapped?.call(index);
                },
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRect(
                        child: Container(
                          padding: EdgeInsets.all(5).w,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                              child: CommonImage(
                                imagePath: item.iconUrl,
                                width: 18.w,
                                height: 18.h,
                                fit: BoxFit.fill,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      5.verticalSpace,
                      if (item.label != null) ...[
                        SizedBox(
                          width: 56.w,
                          child: CommonText(
                            titleText: item.label!,
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w400,
                              color: color,
                            ),
                            maxLines: textScale.scale(1.0) > 1.2 ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildNavBarWithFab(List<NavItemModel> items, BuildContext context) {
  //   final theme = Theme.of(context);
  //   final regularItems = items.where((item) => !item.isFab).toList();

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       // Left items
  //       ...List.generate((regularItems.length / 2).ceil(), (index) {
  //         if (index >= regularItems.length) {
  //           return SizedBox.shrink();
  //         }
  //         final item = regularItems[index];
  //         return GestureDetector(
  //           onTap: () {
  //             onNavItemTapped?.call(index);
  //           },
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 width: 35.w,
  //                 height: 35.h,
  //                 decoration: BoxDecoration(
  //                   color: currentIndex == index
  //                       ? theme.colorScheme.primary
  //                       : theme.colorScheme.surfaceContainerHighest,
  //                   borderRadius: BorderRadius.circular(4.r),
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(4.r),
  //                   child: CommonImage(
  //                     imagePath: item.iconUrl,
  //                     fit: BoxFit.cover,
  //                     label: 'Nav icon',
  //                   ),
  //                 ),
  //               ),
  //               if (item.label != null) ...[
  //                 Container(
  //                   constraints: BoxConstraints(maxWidth: 50.w),
  //                   child: CommonText(
  //                     titleText: item.label!,
  //                     textStyle: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.w900,
  //                       color: currentIndex == index
  //                           ? theme.colorScheme.primary
  //                           : Colors.grey[700],
  //                     ),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         );
  //       }),
  //       // Center spacing for FAB
  //       SizedBox(width: 50.w),
  //       // Right items
  //       ...List.generate((regularItems.length / 2).floor(), (index) {
  //         final actualIndex = (regularItems.length / 2).ceil() + index;
  //         if (actualIndex >= regularItems.length) {
  //           return SizedBox.shrink();
  //         }
  //         final item = regularItems[actualIndex];
  //         return GestureDetector(
  //           onTap: () {
  //             onNavItemTapped?.call(actualIndex);
  //           },
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 width: 35.w,
  //                 height: 35.h,
  //                 decoration: BoxDecoration(
  //                   color: currentIndex == actualIndex
  //                       ? theme.colorScheme.primary
  //                       : theme.colorScheme.surfaceContainerHighest,
  //                   borderRadius: BorderRadius.circular(4.r),
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(4.r),
  //                   child: CommonImage(
  //                     imagePath: item.iconUrl,
  //                     fit: BoxFit.cover,
  //                     label: 'Nav icon',
  //                   ),
  //                 ),
  //               ),
  //               if (item.label != null) ...[
  //                 Container(
  //                   constraints: BoxConstraints(maxWidth: 50.w),
  //                   child: CommonText(
  //                     titleText: item.label!,
  //                     textStyle: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.w900,
  //                       color: currentIndex == actualIndex
  //                           ? theme.colorScheme.primary
  //                           : Colors.grey[700],
  //                     ),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         );
  //       }),
  //     ],
  //   );
  // }
}
