import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme/theme.dart';

class ServiceCard extends BaseStatelessWidget {
  final String titleText;
  final String imageUrl;
  final void Function()? onTap;
  const ServiceCard({
    required this.titleText,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: titleText,
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  Positioned.fill(child: AppImage(imagePath: imageUrl)),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: HyphenatedText(
                        titleText,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: ref
                              .watch(appThemeProvider)
                              .colors
                              .surfaceLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
