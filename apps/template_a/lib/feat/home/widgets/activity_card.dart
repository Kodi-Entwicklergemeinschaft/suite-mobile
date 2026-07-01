import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ActivityCard extends StatelessWidget {
  final String imageUrl;
  final String? tagText;
  final Color? tagBgColor;
  final String? tagIconPath;
  final IconData? tagDefaultIcon;
  final String? title;
  final Color? titleBgColor;
  final Color? titleColor;
  final String? subtitle;
  final Color? subtitleBgColor;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.imageUrl,
    this.tagText,
    this.tagBgColor,
    this.tagIconPath,
    this.tagDefaultIcon,
    this.title,
    this.titleBgColor,
    this.titleColor,
    this.subtitle,
    this.subtitleBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final semanticLabel = [title, tagText, subtitle]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Semantics(
      button: onTap != null,
      label: semanticLabel.isNotEmpty ? semanticLabel : null,
      child: GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // Full background image
              Positioned.fill(
                child: imageUrl.isNotEmpty
                    ? CommonImage(
                        imagePath: imageUrl,
                        fit: BoxFit.cover,
                        label: tagText ?? '',
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (tagBgColor ?? Colors.teal).withValues(alpha: 0.6),
                              tagBgColor ?? Colors.teal,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40.sp,
                            color: Colors.white30,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, bottom: 40.h, right: 40.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tagText != null && tagText!.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.9,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: tagBgColor ?? Colors.teal,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tagIconPath != null && tagIconPath!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: CommonImage(
                                  imagePath: tagIconPath!,
                                  height: 22.h,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: Icon(
                                  tagDefaultIcon ?? Icons.explore,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: CommonText(
                                titleText: tagText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (title != null && title!.isNotEmpty) ...[
                      Container(
                        constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                        padding: EdgeInsets.all(8.h),
                        decoration: BoxDecoration(
                          color: titleBgColor ?? Colors.teal,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.r),
                            bottomRight: Radius.circular(8.r),
                          ),
                        ),
                        child: CommonText(
                          titleText: title!,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: titleColor ?? Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxWidth: screenWidth * 0.55),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: subtitleBgColor ?? Colors.black87,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.r),
                            bottomRight: Radius.circular(8.r),
                          ),
                        ),
                        child: CommonText(
                          titleText: subtitle!,
                          textAlign: TextAlign.start,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
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
    ),
    );
  }
}
