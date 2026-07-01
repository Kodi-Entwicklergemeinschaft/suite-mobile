import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import '../../../core/widgets/carousal_indicator.dart';
import '../../../core/widgets/carousal_widget.dart';

class HighlightCarousel extends StatefulWidget {
  final List<ListingItemCard> items;

  const HighlightCarousel({
    super.key,
    required this.items,
  });

  @override
  State<HighlightCarousel> createState() => _HighlightCarouselState();
}

class _HighlightCarouselState extends State<HighlightCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 400.h,
          child: CarouselWidget(items: widget.items, controller: _controller),
        ),
        SizedBox(height: 12.h),
        CarouselIndicatorWidget(
          itemCount: widget.items.length,
          controller: _controller,
        ),
      ],
    );
  }
}
