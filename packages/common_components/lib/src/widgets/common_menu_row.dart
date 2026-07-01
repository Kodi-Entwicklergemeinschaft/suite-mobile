import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';
import 'common_text.dart';

/// A tappable row with a leading icon, a label, and an optional trailing
/// widget (defaults to a chevron-right arrow).
///
/// Used in profile, settings, and any other menu-style list.
class CommonMenuRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? iconWidget;

  /// Override the trailing widget. Defaults to a chevron-right icon.
  /// Pass [SizedBox.shrink()] to hide the trailing widget.
  final Widget? trailing;

  const CommonMenuRow({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.color,
    this.iconWidget
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTextColors.of(context).normal;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          iconWidget ??
            Icon(icon, size: 24.sp, color: textColor),
          SizedBox(width: 18.w),
          Expanded(
            child: CommonText(
              titleText: label,
              textStyle: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right, size: 20.sp, color: textColor),
        ],
      ),
    );
  }
}
