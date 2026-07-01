import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Simple, elegant filter chip widget
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isSelected
        ? (selectedColor ?? theme.colorScheme.primary)
        : (unselectedColor ?? theme.colorScheme.surface);
    final textColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final borderColor = isSelected
        ? (selectedColor ?? theme.colorScheme.primary)
        : theme.colorScheme.outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.check,
                  size: 16.sp,
                  color: textColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
