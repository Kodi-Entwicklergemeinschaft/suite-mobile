import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';

class MenuItemWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;

  const MenuItemWidget({
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 12.w)],
            Expanded(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: color,
                ),
              ),
            ),
            trailing ??
                CommonImage(
                  imagePath: 'assets/svg/arrow_icon.svg',
                  width: 28.w,
                  height: 28.w,
                  color: Theme.of(context).colorScheme.onSurface,
                  fit: BoxFit.contain,
                ),
          ],
        ),
      ),
    );
  }
}
