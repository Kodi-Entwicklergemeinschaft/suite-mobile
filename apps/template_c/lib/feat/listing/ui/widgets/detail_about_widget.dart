import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

class DetailAboutWidget extends StatelessWidget {
  final String? content;

  const DetailAboutWidget({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    final text = content ?? '';

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: 'Über das Event',
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
            ),
            child: HtmlContentWidget(
              htmlContent: text,
              showMoreText: 'home_show_more'.tr,
              showLessText: 'home_show_less'.tr,
              showMoreColor:  Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
