import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';

import '../../widget/common_widget.dart';

/// First page of the onboarding flow - welcome screen
class WelcomePage extends BaseStatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20.h,
      children: [
        SizedBox(height: 10.h),
        _buildHeader(),
        _buildLogo(),
        _buildSubtitle(ref),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildHeader() {
    return CommonText(
      titleText: 'welcome_header'.tr,
      textAlign: TextAlign.center,
      textScaler: TextScaler.noScaling,
      textStyle: TextStyle(
        color: AppColors.defaultColors.fontLight,
        fontSize: 32.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: onboardingAppLogo(),
    );
  }

  Widget _buildSubtitle(WidgetRef ref) {
    return CommonText(
      textAlign: TextAlign.center,
      titleText: "${'onboarding_title_1'.tr} ${'onboarding_title_2'.trParams(
          {'appName': ref.watch(appThemeProvider).title ?? ''})} ${'onboarding_title_3'.tr}",
      maxLines: 5,
      textScaler: TextScaler.noScaling,
      textStyle: TextStyle(
        color: AppColors.defaultColors.fontLight,
        fontSize: 30.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
