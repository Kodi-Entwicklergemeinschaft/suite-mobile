
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
class BadgeIconWidget extends StatelessWidget {
  const BadgeIconWidget({
    super.key,
    this.height,
    this.width,
    required this.foregroundIconPath,
  });
  final String foregroundIconPath;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
     width:width ??  73.w,
      height:height ?? 73.h,
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          SvgPicture.asset(
            'assets/icons/headline_decoration_badge.svg',
             colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.secondary,
              BlendMode.srcIn,
            ),
          ),
          CommonImage(
          imagePath:foregroundIconPath,
          ),
        ],
      ),
    );
  }
}
