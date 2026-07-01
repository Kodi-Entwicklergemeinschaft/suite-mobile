import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/feat/onboarding/widget/common_widget.dart';
import 'package:template_a/feat/onboarding/widget/page_count_dotted_ui.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_controller.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_state.dart';
import 'package:template_a/core/feature_flags.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;
import 'package:theme/theme.dart';


class UserPreferencesScreen extends BaseStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  String get screenName => RouteConstant.userPreferences.name;

  @override
  ConsumerState<UserPreferencesScreen> createState() =>
      _UserPreferencesScreenState();
}

class _UserPreferencesScreenState
    extends BaseStatefulWidgetState<UserPreferencesScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(termsControllerProvider.notifier)
          .resetNotificationAndNewsLetter();
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final state = ref.watch(termsControllerProvider);
    final appId = appTheme.title ?? '';

    ref.listen(termsControllerProvider, (previous, next) {
      if (next.status == TermsStatusEnum.successNotificationPref) {
        context.go(ref.read(shellConfigProvider.notifier).firstTabPath);
      } else if (next.status == TermsStatusEnum.errorNotificationPref) {
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
            buildWave(animate: _animate, imagePath: Images.wave6Svg, heightFraction: 0.33),
            buildWave(
              animate: _animate,
              imagePath: Images.wave5Svg,
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
              ),
            ),
            onboardingBottomInfo(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: onboardingAppLogo(),
                    ),
                    SizedBox(height: 20.h),
                    if (!state.isNewsLetterScreen) ...[
                      CommonText(
                        titleText: 'push_notifications_title'
                            .trParams({'appId': appId}),
                        semanticsLabel: 'push_notifications_title'
                            .trParams({'appId': appId}),
                        textAlign: TextAlign.center,
                        maxLines: 6,
                        overflow: TextOverflow.visible,
                        textScaler: TextScaler.noScaling,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      CommonText(
                        titleText: 'push_notifications_subtitle'.tr,
                        semanticsLabel: 'push_notifications_subtitle'.tr,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.visible,
                        textScaler: TextScaler.noScaling,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ] else
                      CommonText(
                        titleText: 'newsletter_title'.tr,
                        semanticsLabel: 'newsletter_title'.tr,
                        textAlign: TextAlign.center,
                        maxLines: 6,
                        overflow: TextOverflow.visible,
                        textScaler: TextScaler.noScaling,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                    SizedBox(height: 20.h),
                    if (!state.isNewsLetterScreen)
                      CommonChecklistTile(
                        onTap: () {
                          if (!isNotificationEnabled) {
                            AppSnackBar.showError(context, 'notification_service_disabled'.tr);
                            return;
                          }
                          ref
                              .read(termsControllerProvider.notifier)
                              .toggleNotificationConsent();
                        },
                        text: 'accept_push_notifications'.tr,
                        value: state.hasAcceptedPushNotification,
                        backgroundColor: state.hasAcceptedPushNotification
                            ? Theme.of(context).colorScheme.secondary
                            : TemplateAColors.darkCard,
                        textColor: Colors.white,
                        checkBoxFillColor: Colors.white,
                        checkColor: Colors.white,
                        borderColor: Colors.white,
                        iconColor: Colors.black,
                      )
                    else
                      CommonChecklistTile(
                        onTap: () => ref
                            .read(termsControllerProvider.notifier)
                            .toggleNewsLetterConsent(),
                        text: 'newsletter_permission'.tr,
                        value: state.hasAcceptedNewsLetter,
                        backgroundColor: state.hasAcceptedNewsLetter
                            ? Theme.of(context).colorScheme.secondary
                            : TemplateAColors.darkCard,
                        textColor: Colors.white,
                        checkBoxFillColor: Colors.white,
                        checkColor: Colors.white,
                        borderColor: Colors.white,
                        iconColor: Colors.black,
                      ),
                    SizedBox(height: 10.h),
                    AppButton(
                      (state.isNewsLetterScreen
                              ? 'finish_button'
                              : 'next_button')
                          .tr,
                      type: ButtonType.normal,
                      size: ButtonSize.large,
                      fontSize: 20.sp,
                      bgColor: Theme.of(context).colorScheme.secondary,
                      textColor: Colors.white,
                      loading: state.status ==
                          TermsStatusEnum.loadingNotificationPref,
                      onPressed: () {
                        final controller =
                            ref.read(termsControllerProvider.notifier);
                        if (state.isNewsLetterScreen) {
                          controller.saveNotificationStatus();
                        } else {
                          controller.goToNewsLetter();
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: PageCountDottedUI(
                        totalPage: 6,
                        currentPage: state.isNewsLetterScreen ? 5 : 4,
                      ),
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
