import 'dart:math' as math;

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template_c/core/widgets/badge_icon_widget.dart';

class SliderButton extends StatefulWidget {
  final VoidCallback onComplete;
  final String text;
  final String icon;

  const SliderButton({
    super.key,
    required this.onComplete,
    required this.text,
    required this.icon,
  });

  @override
  State<SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  double position = 0;
  bool isDragging = false;

  final double height = 72;
  final double padding = 12;
  final double knobSize = 48;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, 353.w)
            : 353.w;
        final double trackHeight = height.h;
        final double horizontalPadding = padding.w;
        final double innerWidth =
            math.max(0, trackWidth - (horizontalPadding * 2));
        final double innerHeight =
            math.max(0, trackHeight - (horizontalPadding * 2));
        final double actualKnobSize = math.min(knobSize.w, innerHeight);
        final double maxDrag = math.max(0, innerWidth - actualKnobSize);
        final double effectivePosition = position.clamp(0.0, maxDrag);
        final double fillWidth = effectivePosition == 0
          ? 0
          : (effectivePosition + actualKnobSize / 2)
          .clamp(0.0, innerWidth);
        final double fillHeight = fillWidth.clamp(0.0, actualKnobSize);
        final Color fillColor =
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5);

        return Container(
          width: trackWidth,
          height: trackHeight,
          padding: EdgeInsets.all(horizontalPadding),
          decoration: BoxDecoration(
            color : Colors.black45,
            borderRadius: BorderRadius.circular(48.r),
            border: Border.all(
              color: const Color(0x1AFFFFFF),
              width: 1.w,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              /// Fill background based on drag position
              if (fillWidth > 0 && fillHeight > 0)
                Positioned(
                  left: 0,
                  top: (innerHeight - fillHeight) / 2,
                  child: Container(
                    width: fillWidth,
                    height: fillHeight,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(fillHeight / 2),
                        bottomLeft: Radius.circular(fillHeight / 2),
                      ),
                    ),
                  ),
                ),

              /// Text
              Positioned.fill(
                left: actualKnobSize + 3.w,
                // right: actualKnobSize,
                child: Center(
                  child: CommonText(
                    textAlign: TextAlign.center,
                    titleText: widget.text,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),


              /// Slider knob
              AnimatedPositioned(
                duration: isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: effectivePosition,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    isDragging = true;
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      position += details.delta.dx;

                      if (position < 0) position = 0;
                      if (position > maxDrag) position = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    isDragging = false;

                    if (position > maxDrag * 0.9) {
                      widget.onComplete();

                      setState(() {
                        position = maxDrag;
                      });
                    } else {
                      setState(() {
                        position = 0;
                      });
                    }
                  },
                  child: Container(
                    width: actualKnobSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: BadgeIconWidget(
                        foregroundIconPath: widget.icon,
                        
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}