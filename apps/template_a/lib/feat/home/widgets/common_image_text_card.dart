import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';


class CommonImageTextCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Color titleColor;
  final double? fontSize;
  final bool isSelected;
  final VoidCallback? onTap;

  const CommonImageTextCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.titleColor,
    this.fontSize,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 160;
    const double height = 160;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      button: onTap != null,
      label: title,
      selected: isSelected,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: width.w,
        height: height.h,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          border: isSelected
              ? Border.all(color: titleColor, width: 4.w)
              : null,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              child: imageUrl.isNotEmpty
                  ? CommonImage(
                      imagePath: imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingWidget: ShimmerWidget(
                        baseColor: titleColor.withValues(alpha: 0.4),
                        highlightColor: titleColor.withValues(alpha: 0.7),
                        child: Container(
                          height: height.h,
                          width: width.w,
                          color: titleColor.withValues(alpha: 0.3),
                        ),
                      ),
                    )
                  : Container(
                      color: titleColor.withValues(alpha: 0.3),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 30.sp,
                          color: Colors.white30,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h, right: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    constraints: BoxConstraints(maxWidth: width.w),
                    decoration: BoxDecoration(
                      color: titleColor,
                      borderRadius: isRTL
                          ? BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              bottomLeft: Radius.circular(8.r),
                            )
                          : BorderRadius.only(
                              topRight: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r),
                            ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 10.h,
                        left: 10.w,
                        right: 10.w,
                        bottom: 10.h,
                      ),
                      child: CommonText(
                        titleText: title,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textStyle: TextStyle(
                          fontSize: fontSize ?? 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
