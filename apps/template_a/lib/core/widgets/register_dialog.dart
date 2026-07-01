import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/feat/auth/controllers/auth_controller.dart';
import 'package:template_a/feat/onboarding/controller/onboarding_controller.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:theme/theme.dart';

void showRegisterDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      final theme = Theme.of(dialogCtx);
      return Dialog(
        backgroundColor: theme.extension<AppContainerColors>()!.inverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 52.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonText(
                  titleText: 'login_to_enable_feature'.tr,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: CommonText(
                      titleText: 'cancel'.tr,
                      textStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogCtx).pop();
                      await ref
                          .read(authControllerProvider.notifier)
                          .clearGuestSession();
                      if (context.mounted) {
                        context.goNamed(RouteConstant.onboarding.name);
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(onboardingControllerProvider.notifier)
                            .onPageChanged(3);
                      });
                    },
                    child: CommonText(
                      titleText: 'register'.tr,
                      textStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
