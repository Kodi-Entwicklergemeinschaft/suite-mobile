import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_a/feat/bottom_navigation/model/bottom_nav_bar_model.dart';
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

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: (textScale.scale(1.0) > 1.2 ? 104.h : 80.h) + bottomPadding,
      padding: EdgeInsets.only(
        top: 16.h,
        left: 24.w,
        bottom: 6.h + bottomPadding,
        right: 24.w,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.scrim.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(config.items.length, (index) {
          final item = config.items[index];
          final isSelected = currentIndex == index;
          Color? color = isSelected
              ? theme.colorScheme.secondary
              : Colors.white;
          return Expanded(
            child: Semantics(
              button: true,
              label: item.label,
              selected: isSelected,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onNavItemTapped?.call(index),
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30.w,
                        height: 30.h,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          child: CommonImage(
                            imagePath: item.iconUrl,
                            fit: BoxFit.contain,
                            color: color,
                          ),
                        ),
                      ),
                      5.verticalSpace,
                      if (item.label != null) ...[
                        CommonText(
                          titleText: item.label!,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
