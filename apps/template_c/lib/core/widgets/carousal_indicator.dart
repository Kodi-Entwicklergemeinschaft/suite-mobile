import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselIndicatorWidget extends StatelessWidget {
  final int itemCount;
  final PageController controller;

  const CarouselIndicatorWidget({
    super.key,
    required this.itemCount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final currentIndex = (controller.page ?? 0).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (index) {
            final isActive = index == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 6.h,
              width: isActive ? 20.w : 6.w,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            );
          }),
        );
      },
    );
  }
}
