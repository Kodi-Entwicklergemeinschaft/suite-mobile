// ...existing code...
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/services/presentation/shimmer/card_layout_shimmer.dart';

class ServiceShimmerScreen extends StatelessWidget {
  const ServiceShimmerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Semantics(
          label: 'loading_label'.tr,
          excludeSemantics: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonShimmer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CommonShimmer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(height: 48.h, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                16.verticalSpace,

                CommonShimmer(
                  child: Container(
                    height: 40.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),

                16.verticalSpace,

                CardLayoutShimmer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
