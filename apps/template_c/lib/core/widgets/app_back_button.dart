import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// A back button using the app's standard arrow SVG asset, horizontally
/// flipped so the arrow points left (the SVG points right by default).
///
/// Tapping calls [onTap] if provided, otherwise [context.pop()].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.pop(),
      child: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Transform.flip(
        flipX: true,
        child: SvgPicture.asset(
          'assets/icons/arrow_icon.svg',
          width: 24.w,
          height: 24.h,
          colorFilter: ColorFilter.mode(
            Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
      ),
    );
  }
}
