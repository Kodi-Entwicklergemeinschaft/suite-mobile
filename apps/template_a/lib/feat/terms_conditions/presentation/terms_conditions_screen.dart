import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/feat/onboarding/widget/common_widget.dart';
import 'package:template_a/feat/onboarding/widget/page_count_dotted_ui.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_controller.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_state.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;
import 'package:theme/theme.dart';


class TermsConditionsScreen extends BaseStatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  String get screenName => RouteConstant.termsConditions.name;

  @override
  ConsumerState<TermsConditionsScreen> createState() =>
      _TermsConditionsScreenState();
}

class _TermsConditionsScreenState
    extends BaseStatefulWidgetState<TermsConditionsScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(termsControllerProvider.notifier).resetTerms();
      if (mounted) setState(() => _animate = true);
      ref.read(termsControllerProvider.notifier).getLatestTerms();
    });
  }

  void _openWebView(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommonWebViewWidget(
          params: CommonWebViewWidgetParams(
            url: url,
            title: title,
            showCloseButton: true,
            appBarHeight: 64,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);
    final state = ref.watch(termsControllerProvider);
    final isGuest = ref.watch(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
    final appId = appTheme.title ?? '';

    ref.listen(termsControllerProvider, (previous, next) {
      if (next.status == TermsStatusEnum.successTermsAndCondition) {
        if (isGuest) {
          context.go(ref.read(shellConfigProvider.notifier).firstTabPath);
        } else {
          context.goNamed(RouteConstant.userPreferences.name);
        }
      } else if (next.status == TermsStatusEnum.errorTermAndCondition) {
        AppSnackBar.showError(context, next.errorMessage);
      }
    });

    final logoUrl = appTheme.assets?.logoUrl ?? '';

    return Scaffold(
      backgroundColor: TemplateAColors.darkModeBackground,
      appBar: AppBar(
        toolbarHeight: 120.h,
        titleSpacing: 10,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: logoUrl.isEmpty
            ? null
            : CommonImage(
                imagePath: logoUrl,
                height: 100.h,
              ),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildWave(animate: _animate, imagePath: Images.wave5Svg, heightFraction: 0.33),
            buildWave(
              animate: _animate,
              imagePath: Images.wave6Svg,
              reverse: true,
              heightFraction: 0.33,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: onboardingBuildings(
                animate: _animate,
                initialStart: 0.07,
                finalStart: 0.45,
                slideForward: false,
              ),
            ),
            onboardingBottomInfo(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: onboardingAppLogo(),
                    ),
                    SizedBox(height: 20.h),

                    CommonText(
                      titleText: 'terms_and_conditions_title'.tr,
                      semanticsLabel: 'terms_and_conditions_title'.tr,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                      textScaler: TextScaler.noScaling,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    CommonText(
                      titleText: 'terms_and_conditions_subtitle'
                          .trParams({'appId': appId}),
                      semanticsLabel: 'terms_and_conditions_subtitle'
                          .trParams({'appId': appId}),
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                      textScaler: TextScaler.noScaling,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    InfoTile(
                      text: 'view_terms_and_conditions'.tr,
                      backgroundColor: TemplateAColors.darkCard,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () =>
                          _openWebView(state.termsUrl, 'terms_of_use'.tr),
                    ),
                    SizedBox(height: 8.h),
                    InfoTile(
                      text: 'view_privacy_policy'.tr,
                      backgroundColor: TemplateAColors.darkCard,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () =>
                          _openWebView(state.privacyUrl, 'privacy_policy'.tr),
                    ),
                    SizedBox(height: 22.h),

                    CommonChecklistTile(
                      onTap: () => ref
                          .read(termsControllerProvider.notifier)
                          .toggleTerms(),
                      text: 'accept_terms_and_conditions'.tr,
                      value: state.hasAcceptedConsent,
                      backgroundColor: state.hasAcceptedConsent
                          ? Theme.of(context).colorScheme.secondary
                          : TemplateAColors.darkCard,
                      textColor: Colors.white,
                      checkBoxFillColor: Colors.white,
                      checkColor: Colors.white,
                      borderColor: Colors.white,
                      iconColor: Colors.black,
                    ),
                    SizedBox(height: 30.h),
                    AppButton(
                      (isGuest ? 'finish_button' : 'next_button').tr,
                      disabled: !state.hasAcceptedConsent,
                      loading: state.status ==
                          TermsStatusEnum.loadingTermsAndCondition,
                      type: ButtonType.normal,
                      size: ButtonSize.large,
                      fontSize: 20.sp,
                      bgColor: state.hasAcceptedConsent
                          ? Theme.of(context).colorScheme.secondary
                          : const Color(0xFF2C4158),
                      textColor: Colors.white,
                      onPressed: () => ref
                          .read(termsControllerProvider.notifier)
                          .saveTermsStatus(),
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: PageCountDottedUI(totalPage: 6, currentPage: 3),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}