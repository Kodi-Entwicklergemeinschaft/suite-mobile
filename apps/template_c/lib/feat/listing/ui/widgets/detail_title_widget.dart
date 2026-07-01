import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class DetailTitleWidget extends StatelessWidget {
  final String title;
  final String? subcategoryTitle;
  final String? categoryTitle;

  const DetailTitleWidget({
    super.key,
    required this.title,
    this.subcategoryTitle,
    this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubcategory = subcategoryTitle?.isNotEmpty == true;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      child: Column(
        children: [
          CommonText(
            titleText: title.toUpperCase(),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            textStyle: context.templateColors.secondaryTextTheme?.titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 36.sp,
                  height: 1.0,
                ),
          ),
          SizedBox(height: 8.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  // text: 'listing_event'.tr,
                  text: categoryTitle ?? 'listing_event'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (hasSubcategory)
                  TextSpan(
                    text: ' · ${subcategoryTitle ?? ''}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF808080),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
