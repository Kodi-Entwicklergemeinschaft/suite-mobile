import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonArrowBackTitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CommonArrowBackTitleWidget(
      {super.key, required this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonIcon(
          onPressed: onBackPressed,
          icon: Icons.arrow_back,
          size: 24.h,
        ),
        Expanded(
          child: Center(
            child: CommonText(
              titleText: title,
              textStyle: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
