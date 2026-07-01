import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/widgets/template_chip.dart';

class DetailAccessibilityWidget extends StatelessWidget {
  final String? description;
  final List<String>? features;

  const DetailAccessibilityWidget({super.key, this.description, this.features});

  bool get _hasContent =>
      (description?.isNotEmpty == true) || (features?.isNotEmpty == true);

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: 'accessibility'.tr,
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          if (description?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            CommonText(
              titleText: description ?? '',
              overflow: TextOverflow.visible,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.71,
              ),
            ),
          ],
          if (features?.isNotEmpty == true) ...[
            SizedBox(height: 24.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: features!
                  .map(
                    (label) => TemplateChip(
                      label: label,
                      prefixIcon: Icon(
                        Icons.check_circle_outline,
                        size: 16.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
