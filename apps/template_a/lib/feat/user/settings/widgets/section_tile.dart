import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:theme/theme.dart';

class SectionTile extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? iconImage;
  final String? label;

  const SectionTile(
    this.text, {
    super.key,
    this.icon,
    this.onTap,
    this.iconImage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final inverseColor = Theme.of(context).extension<AppTextColors>()!.inverse;

    return Semantics(
      button: onTap != null,
      label: text,
      child: InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            if (iconImage != null)
              CommonImage(
                imagePath: iconImage!,
                color: inverseColor,
                width: 35.w,
                label: label,
              )
            else if (icon != null)
              CommonIcon(
                icon: icon!,
                label: label,
                size: 35.w,
                color: inverseColor,
              ),
            SizedBox(width: 8.w),
            Flexible(
              child: CommonText(
                titleText: text,
                overflow: TextOverflow.ellipsis,
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: inverseColor,
                    ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
