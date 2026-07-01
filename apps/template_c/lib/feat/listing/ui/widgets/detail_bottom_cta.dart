import 'dart:ui';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class DetailBottomCta extends BaseStatelessWidget {
  final String? registrationUrl;
  final VoidCallback? onTap;

  const DetailBottomCta({super.key, this.registrationUrl, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (registrationUrl?.isNotEmpty != true) return const SizedBox.shrink();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(255, 255, 255, 0.8)
                    : const Color.fromRGBO(35, 44, 57, 0.7),
                width: 1.w,
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: AppButton(
            'listing_detail_cta_book_ticket'.tr,
            borderRadius: 100.r,
            onPressed: onTap,
           ),
          ),
        ),
      ),
    );
  }
}
