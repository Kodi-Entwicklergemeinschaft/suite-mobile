import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateBadge extends StatelessWidget {
  final String date;
  final String month;
  final Color backgroundColor;
  final Color dateTextColor;
  final Color monthTextColor;
  final double? width;
  final double? borderRadius;

  const DateBadge({
    super.key,
    required this.date,
    required this.month,
    this.backgroundColor = const Color(0xFF151B23),
    this.dateTextColor = Colors.white,
    this.monthTextColor = const Color(0xFFC1CAD5),
    this.width = 44,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (date.isEmpty || month.isEmpty) return SizedBox.shrink();
    return Container(
      width: (width ?? 44).w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular((borderRadius ?? 8).r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            titleText: date,
            textStyle: TextStyle(
              color: dateTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 19.sp,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            month,
            style: TextStyle(color: monthTextColor, fontSize: 12.sp, height: 1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
