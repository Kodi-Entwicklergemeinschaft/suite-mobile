import 'package:common_components/common_components.dart';
import 'package:common_components/src/animations/slide_common_image_partial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

import '../../../core/constant/image.dart';

/// Onboarding main brand logo (center splash image).
/// No args — reads BE-provided `splashUrl` from the theme internally.
class OnboardingAppLogo extends BaseStatelessWidget {
  const OnboardingAppLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(appThemeProvider).assets?.splashUrl ?? '';
    if (imageUrl.isEmpty) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    return CommonImage(
      imagePath: imageUrl,
      width: screenWidth * 0.65,
      fit: BoxFit.contain,
    );
  }
}

/// Call site: `onboardingAppLogo()` — no args.
Widget onboardingAppLogo() => const OnboardingAppLogo();

/// Animated buildings widget for onboarding background
Widget onboardingBuildings({
  required bool animate,
  required double initialStart,
  required double finalStart,
  bool slideForward = true,
}) {
  return AspectRatio(
    aspectRatio: 1200 / 661,
    child: SlideCommonImagePartial(
      slideForward: slideForward,
      animate: animate,
      initialStart: initialStart,
      initialWindowFraction: 0.5,
      finalStart: finalStart,
      duration: const Duration(milliseconds: 1200),
      image: CommonImage(
        imagePath: Images.buildings,
        color: Colors.white,
        fit: BoxFit.cover,
      ),
    ),
  );
}

/// Animated wave widget for onboarding background
Widget buildWave({
  required bool animate,
  required String imagePath,
  bool reverse = false,
  Duration duration = const Duration(milliseconds: 1500),
  Curve curve = Curves.easeOutCubic,
  double? heightFraction,
}) {
  return _BuildWaveWidget(
    animate: animate,
    imagePath: imagePath,
    reverse: reverse,
    duration: duration,
    curve: curve,
    heightFraction: heightFraction,
  );
}

class _BuildWaveWidget extends StatelessWidget {
  final bool animate;
  final String imagePath;
  final bool reverse;
  final Duration duration;
  final Curve curve;
  final double? heightFraction;

  const _BuildWaveWidget({
    required this.animate,
    required this.imagePath,
    required this.reverse,
    required this.duration,
    required this.curve,
    this.heightFraction,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: heightFraction != null ? screenHeight * heightFraction! : null,
      child: AnimatedSlide(
        offset: animate
            ? (reverse ? const Offset(0, 0.4) : Offset.zero)
            : (reverse ? Offset.zero : const Offset(0, 0.4)),
        duration: duration,
        curve: curve,
        child: CommonImage(imagePath: imagePath, fit: heightFraction != null ? BoxFit.fill : BoxFit.fitWidth),
      ),
    );
  }
}

/// Bottom info widget for onboarding
Widget onboardingBottomInfo() {
  return Positioned(
    bottom: 10.h,
    right: 10.h,
    child: SizedBox(
      height: 52.h,
      child: CommonImage(
        imagePath: Images.bottomInfo,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}
