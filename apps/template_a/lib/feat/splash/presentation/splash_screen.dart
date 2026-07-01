import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

import '../../../core/constant/image.dart';
import '../../../core/utils/template_a_colors.dart';
import '../controller/splash_controller.dart';
import '../../../router/route_constant.dart';

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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final state = ref.watch(splashControllerProvider);
    final appTheme = ref.watch(appThemeProvider);

    // Single Scaffold — background never changes, so there's no colour flash.
    // The wave/logo content fades in once the theme is ready.
    // The spinner is one persistent widget that is never unmounted, so its
    // rotation animation runs continuously with no reset.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
      backgroundColor: TemplateAColors.darkModeBackground,
      body: Stack(
        children: [
          // Wave + logo layer — fades in when splash is ready
          AnimatedOpacity(
            opacity: state.isSplashReady ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(flex: 5, child: const SizedBox()),
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CommonImage(
                                imagePath: Images.wave2Svg,
                                fit: BoxFit.cover,
                                width: w,
                              ),
                            ),
                            Positioned(
                              top: h * 0.15,
                              right: w * 0.01,
                              child: CommonImage(
                                imagePath: Images.wave4Svg,
                                width: w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: h * 0.13,
                              left: 0,
                              right: 0,
                              child: CommonImage(
                                imagePath: Images.wave3Svg,
                                width: w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: h * 0.25,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: CommonImage(
                                imagePath: Images.wave1Svg,
                                width: w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Title + logo
                Positioned(
                  top: h * 0.28,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CommonText(
                        titleText: 'splash_title'.tr,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: h * 0.015),
                      if ((appTheme.assets?.splashUrl ?? '').isNotEmpty)
                        CommonImage(
                          width: w / 2,
                          imagePath: appTheme.assets!.splashUrl!,
                        ),
                    ],
                  ),
                ),

                // Birds
                Positioned(
                  top: h * 0.10,
                  right: w * 0.05,
                  child: CommonImage(
                      imagePath: Images.birdsSvg, height: h * 0.05),
                ),
                Positioned(
                  top: h * 0.14,
                  right: w * 0.25,
                  child: CommonImage(
                      imagePath: Images.birdsSvg, height: h * 0.05),
                ),

                // Lighthouse
                Positioned(
                  bottom: h * 0.24,
                  right: w * 0.1,
                  child: CommonImage(
                    imagePath: Images.lightHouseSvg,
                    height: h * 0.22,
                    width: w * 0.22,
                  ),
                ),
              ],
            ),
          ),

          // Single persistent spinner — lives outside AnimatedOpacity so it
          // is never unmounted between the two states. One widget, one
          // animation controller, zero resets.
          Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

          if (state.hasError)
            Positioned.fill(
              child: Center(
                child: Text(
                  state.error!,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
