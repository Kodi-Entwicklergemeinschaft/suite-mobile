import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BadgeIcon extends StatelessWidget {
  final IconData icon;

  const BadgeIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            "assets/Vector.svg",
            width: 48.w,
            height: 48.w,
          ),

          Icon(
            icon,
            size: 22.sp,
            color: const Color(0xFF2E2A8F), // match figma gear color
          ),
        ],
      ),
    );
  }
}