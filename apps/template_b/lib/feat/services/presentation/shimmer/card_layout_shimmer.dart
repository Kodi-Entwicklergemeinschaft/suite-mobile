import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

class CardLayoutShimmer extends StatelessWidget {
  const CardLayoutShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: 'loading_label'.tr,
        excludeSemantics: true,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 24.h,

            childAspectRatio: 164.h / 240.w,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => CommonShimmer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(decoration: BoxDecoration(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
