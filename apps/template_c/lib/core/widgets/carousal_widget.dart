import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselWidget extends StatelessWidget {
  final List<Widget> items;
  final PageController controller;

  const CarouselWidget({
    super.key,
    required this.items,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      clipBehavior: Clip.none,
      controller: controller,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: items[index],
        );
      },
    );
  }
}
