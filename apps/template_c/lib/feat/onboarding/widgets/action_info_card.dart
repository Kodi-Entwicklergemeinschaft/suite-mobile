import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';
import 'package:template_c/feat/onboarding/widgets/badge_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onTap;
  final String? icon;

  const ActionInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        /// CARD
        InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF), // #FFFFFF1A

              borderRadius: BorderRadius.circular(24.r),

              border: Border.all(
                color: const Color(0x80FFFFFF), // #FFFFFF80
                width: 1,
              ),

              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000), // #00000014
                  offset: Offset(0, 8),
                  blurRadius: 54,
                  spreadRadius: 0,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                CommonText(
                  titleText: title,
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 0.2
                  ),  
                ),

                SizedBox(height: 8.h),

                /// DESCRIPTION
                CommonText(
                  titleText: description,
                  textStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    height: 1.5,
                    letterSpacing: 0.2
                  ),
                  overflow: TextOverflow.visible,
                ),

                SizedBox(height: 24.h),

                /// ACTION ROW
                InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      children: [
                        CommonText(
                          titleText: actionText,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: 0,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/svg/right-arrow-icon.svg",
                            width: 26,
                            height: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        /// FLOATING ICON BADGE
        if (icon != null)
          Positioned(
            right: 22.95.w,
            top: -26.23.h,
            child: Container(
              alignment: Alignment.center,
              child: BadgeIconWidget(
              foregroundIconPath: icon??"",
                width: 60.w,
                height: 60.h,
              ),
            ),
          ),
        ],
    );
  }
}