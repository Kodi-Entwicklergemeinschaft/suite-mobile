import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/secure_preferences.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/utils/background_gradient.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/splash/controller/splash_controller.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:theme/theme.dart';

class SplashScreen extends BaseStatefulWidget {
  const SplashScreen({super.key});

  @override
  String get screenName => RouteConstant.splash.name;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseStatefulWidgetState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(splashControllerProvider.notifier).initializeApp(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefManger = ref.read(securePreferencesProvider);
    final normalPrefManager = ref.read(preferenceManagerProvider);

    ref.listen(splashControllerProvider, (previous, next) async {
      if (previous != next) {
        if (next.isThemeLoaded) {
          final token = await prefManger.getString(StorageKeys.authAccessToken);
          final isGuestUser =
              normalPrefManager.getStringOrEmpty(StorageKeys.authRole) ==
              UserRole.guest.value;

          if (token != null && token.isNotEmpty && !isGuestUser) {
            if (context.mounted) {
              if (normalPrefManager.getBool(StorageKeys.isOnboarded)) {
                context.goNamed(RouteConstant.bottomNav.name);
              } else {
                context.goNamed(
                  RouteConstant.locationOnboarding.name,
                  extra: LocationOnboardingParams(
                    isSkip: true,
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
              }
            }
          } else {
            if (context.mounted) {
              context.goNamed(RouteConstant.onboarding.name);
            }
          }
        }
      }
    });

    final state = ref.watch(splashControllerProvider);
    final appTheme = ref.watch(appThemeProvider);

    if (state.stateConstant == StateConstant.loading) {
      return Scaffold(body: _buildLoader());
    }

    if (state.hasError) {
      return Scaffold(body: _buildError(state.error!));
    }

    return Scaffold(body: _buildSplash(appTheme));
  }

  Widget _buildLoader() {
    return TemplateCLoader();
  }

  Widget _buildSplash(AppTheme appTheme) {
    final gradient = context.templateColors.splashGradient;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: gradient),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 193.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appTheme.assets?.splashUrl.isNotEmpty == true)
                AppImage(
                  imagePath: appTheme.assets!.splashUrl,
                  height: 250.h,
                  width: 250.h,
                )
              else
                SizedBox(height: 250.h),

              SizedBox(height: 60.h),

              if (appTheme.title != null)
                CommonText(
                  titleText: appTheme.title!,
                  textAlign: TextAlign.center,
                  textStyle: context
                      .templateColors
                      .secondaryTextTheme
                      ?.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 60.sp,
                        color: Colors.white,
                        height: 0.9,
                        letterSpacing: 1.2,
                      ),
                  overflow: TextOverflow.visible,
                ),

              SizedBox(height: 18.h),

              if (appTheme.description != null)
                CommonText(
                  titleText: appTheme.description!,
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
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      child: Center(
        child: CommonText(
          titleText: error,
          textStyle: TextStyle(fontSize: 16.sp),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
