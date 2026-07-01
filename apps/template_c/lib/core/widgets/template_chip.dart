import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class TemplateChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final double? height;

  const TemplateChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.prefixIcon,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height?.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: height == null ? 10.h : 0),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.secondary
              : context.templateColors.chipBg,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Theme.of(context).colorScheme.onSecondary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
