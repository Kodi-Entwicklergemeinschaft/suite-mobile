


import 'package:flutter/material.dart';

/// A reusable widget that moves *any* child widget upward by [distance]
/// when [animate] is true. Optionally place a [filler] below the child
/// (renders behind the moving child).
///
/// Mirrors the behaviour of the original `MoveUpWithFiller` but works for
/// any widget (not just images).
class MoveUpWithFiller extends StatefulWidget {
  final Widget child;
  final double distance;
  final Widget? filler;
  final Duration duration;
  final bool animate;
  final Curve curve;
  final Alignment alignment;

  const MoveUpWithFiller({
    super.key,
    required this.child,
    this.distance = 20.0,
    this.filler,
    required this.animate,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.center,
  });

  @override
  State<MoveUpWithFiller> createState() => _MoveUpWithFillerState();
}

class _MoveUpWithFillerState extends State<MoveUpWithFiller> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: widget.alignment,
      children: [
        if (widget.filler != null) widget.filler!,

        AnimatedSlide(
          duration: widget.duration,
          curve: widget.curve,

          // IMPORTANT: translate by FRACTION, not pixels.
          // Convert your distance (pixels) to a fraction of screen height:
          offset: widget.animate
              ? Offset(0, -widget.distance / MediaQuery.of(context).size.height)
              : Offset.zero,

          child: widget.child,
        ),
      ],
    );
  }
}
