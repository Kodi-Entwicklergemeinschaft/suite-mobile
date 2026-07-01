import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/utils/background_gradient.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/custom_input_field.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/onboarding/controller/onboarding_controller.dart';
import 'package:template_c/feat/onboarding/widgets/action_info_card.dart';
import 'package:template_c/feat/onboarding/widgets/slider_button.dart';
import 'package:template_c/router/route_constant.dart';

class OnboardingScreen extends BaseStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  String get screenName => RouteConstant.onboarding.name;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends BaseStatefulWidgetState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(onboardingControllerProvider.notifier).authenticateGuest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    if (state.stateConstant == StateConstant.error) {
      return const Center(child: Text('Failed to load theme'));
    }

    // if (state.stateConstant == StateConstant.loading) {
    //   return Center(child: CommonCircularProgessIndicator());
    // }

    return Container(
      // padding: const EdgeInsets.only(top: 50.0),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.templateColors.splashGradient,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 120.h),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CommonText(
                    titleText: "splash_welcome_title".tr,
                    textAlign: TextAlign.center,
                    textStyle: context
                        .templateColors
                        .secondaryTextTheme
                        ?.bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 60.0.sp,
                          color: Colors.white,
                          height: 0.9,
                          letterSpacing: 1.2,
                        ),
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(height: 18.h),
                CommonText(
                  titleText: "splash_welcome_subtitle".tr,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0.sp,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            SizedBox(height: 28.23.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
              child: Column(
                children: [
                  ActionInfoCard(
                    title: "splash_personalize_title".tr,
                    description: "splash_personalize_description".tr,
                    actionText: "splash_personalize_action".tr,
                    icon: "assets/svg/icon-settings.svg",
                    onTap: () {
                      context.pushNamed(
                        RouteConstant.locationOnboarding.name,
                        extra: LocationOnboardingParams(
                          isSkip: false,
                          onConfirm: (context) {
                            context.pushNamed(
                              RouteConstant.interestSelection.name,
                              extra: InterestSelectionParams(
                                isSkip: true,
                                onConfirm: (context) {
                                  context.goNamed(RouteConstant.bottomNav.name);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  ActionInfoCard(
                    title: "splash_create_account_title".tr,
                    description: "splash_create_account_description".tr,
                    actionText: "splash_create_account_action".tr,
                    // icon: Icons.person,
                    onTap: () {
                      context.pushNamed(RouteConstant.signup.name);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 48.h),

            SliderButton(
              onComplete: () {
                context.goNamed(RouteConstant.bottomNav.name);
              },
              text: "swipe_to_start_quickly".tr,
              icon: "assets/svg/splash_slider_button_icon.svg",
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
