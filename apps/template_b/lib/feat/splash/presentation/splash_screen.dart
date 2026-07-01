import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:theme/theme.dart' show appThemeProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:template_b/core/utils/session_expire_dialog.dart';
import '../controllers/splash_controller.dart';

/// Splash screen shown during app bootstrap
///
/// This screen is displayed while the app initializes critical data.
/// Watches splash controller and navigates to home when initialization succeeds.
class SplashScreen extends BaseStatefulWidget {
  const SplashScreen({super.key});

  @override
  String get screenName => AppRouteConstants.splash.name;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseStatefulWidgetState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize app after frame is rendered

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final splashState = ref.watch(splashControllerProvider);

    // Navigate to home when initialization succeeds
    ref.listen(splashControllerProvider, (previous, next) {
      debugPrint(
        'Splash: Listen triggered - isLoading: ${next.isLoading}, isSuccess: ${next.isSuccess}, hasError: ${next.hasError}',
      );

      if (next.isSuccess && !next.isLoading) {
        debugPrint('Splash: Success state detected');
        Future.delayed(const Duration(seconds: 2), () {
          if (!context.mounted) return;
          if (SessionExpireDialog.isShowing) return;
          context.goNamed(AppRouteConstants.bottomNavigation.name);
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? appTheme.colors.darkBackground
          : appTheme.colors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (splashState.isLoading)
              Center(child: CommonCircularProgessIndicator())
            else if (appTheme.assets?.splashUrl != null &&
                appTheme.assets!.splashUrl!.isNotEmpty)
              SizedBox(
                width: 160.r,
                height: 160.r,
                child: CommonImage(
                  imagePath: appTheme.assets!.splashUrl!,
                  fit: BoxFit.contain,
                ),
              )
            else
              SizedBox(width: 160.r, height: 160.r),

            // Title
            SizedBox(height: 24.h),
            Visibility(
              visible: false,
              child: CommonText(
                titleText: 'Wunsiedel',
                textStyle: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
