import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PageCountDottedUI extends StatelessWidget {
  final int totalPage;
  final int currentPage;

  const PageCountDottedUI({
    super.key,
    required this.totalPage,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Align(
        alignment: Alignment.center,
        child: Semantics(
          label: "page_count_label".tr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6.h, // spacing between dots
            children: List.generate(totalPage, (index) {
              final bool isActive = index == currentPage;
              return Container(
                height: 12.h,
                width: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors
                            .defaultColors.surfaceLight // ACTIVE dot
                      : AppColors.defaultColors.surfaceLight.withAlpha(40), // INACTIVE dot
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
