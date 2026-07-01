import 'dart:ui';
import 'package:flutter/material.dart';
import '../../common_components.dart';

/// Reliable partial-pan widget for CommonImage.
///
/// - initialStart: where initial window begins (0..1)
/// - initialWindowFraction: how much of full image width initial window covers (0..1)
/// - finalStart, finalWindowFraction: same for final
/// - slideForward: true => initial -> final, false => final -> initial
/// - animate: when true the animation runs; when false it snaps to the corresponding start state
class SlideCommonImagePartial extends StatefulWidget {
  final CommonImage image;
  final bool animate;
  final bool slideForward;
  final Duration duration;
  final Curve curve;

  final double initialStart;
  final double initialWindowFraction;
  final double finalStart;
  final double finalWindowFraction;

  const SlideCommonImagePartial({
    super.key,
    required this.image,
    this.animate = false,
    this.slideForward = true,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    this.initialStart = 0.0,
    this.initialWindowFraction = 0.5,
    this.finalStart = 0.4,
    this.finalWindowFraction = 0.5,
  })  : assert(initialStart >= 0 && initialStart <= 1),
        assert(finalStart >= 0 && finalStart <= 1),
        assert(initialWindowFraction > 0 && initialWindowFraction <= 1),
        assert(finalWindowFraction > 0 && finalWindowFraction <= 1);

  @override
  State<SlideCommonImagePartial> createState() =>
      _SlideCommonImagePartialState();
}

class _SlideCommonImagePartialState
    extends State<SlideCommonImagePartial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);

    // Always initialize to 0.0 so the "start" mapping (which may be initial or final
    // depending on slideForward) is visible when not animating.
    _ctrl.value = 0.0;

    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  @override
  void didUpdateWidget(covariant SlideCommonImagePartial old) {
    super.didUpdateWidget(old);

    if (widget.duration != old.duration) {
      _ctrl.duration = widget.duration;
    }

    // start animation when animate flips false->true
    if (widget.animate && !old.animate) _run();

    // stop animation (snap) when animate flips true->false -> snap to start (t=0)
    if (!widget.animate && old.animate) {
      _ctrl.value = 0.0;
    }

    // if direction changed while not animating, snap to the new "start" mapping
    if (!widget.animate && widget.slideForward != old.slideForward) {
      _ctrl.value = 0.0;
    }

    // NEW: if direction changed while animating (or animate already true), restart animation
    // so we actually run final->initial (or initial->final) depending on slideForward.
    if (widget.animate && widget.slideForward != old.slideForward) {
      _run();
    }
  }

  void _run() {
    // ALWAYS run the controller forward 0.0 -> 1.0.
    // The widget chooses start/end transforms based on slideForward, so the
    // same forward motion will produce initial->final (forward) or final->initial (backward).
    // Ensure we restart cleanly if it's already running.
    _ctrl
      ..stop()
      ..forward(from: 0.0);
  }

  /// Compute scale & translate for a given (startFrac, windowFrac) pair,
  /// given that we render the "mapped image" into a box of width = mappedWidth,
  /// where mappedWidth = viewportW * mappingFactor. We'll keep mappingFactor = 2
  /// for compatibility with previous approach (you can adjust if needed).
  Map<String, double> _computeFor(double viewportW, double startFrac, double windowFrac) {
    const mappingFactor = 2.0;
    final mappedWidth = viewportW * mappingFactor;

    final s = startFrac.clamp(0.0, 1.0);
    final w = windowFrac.clamp(0.0001, 1.0);

    final startPx = s * mappedWidth;
    final windowPx = (w * mappedWidth).clamp(1.0, mappedWidth);

    final scale = viewportW / windowPx; // scale so windowPx fits viewport
    final translate = -startPx * scale; // shift so viewport samples startPx..startPx+windowPx

    return {'scale': scale, 'translate': translate, 'mappedWidth': mappedWidth};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bc) {
      final viewportW = bc.maxWidth;
      final viewportH = bc.maxHeight;

      // get transforms for initial and final windows
      final tInit = _computeFor(viewportW, widget.initialStart, widget.initialWindowFraction);
      final tFin = _computeFor(viewportW, widget.finalStart, widget.finalWindowFraction);

      // determine start & end transforms depending on slideForward:
      // - slideForward == true  => start = initial, end = final
      // - slideForward == false => start = final,   end = initial
      final double startScale = widget.slideForward ? tInit['scale']! : tFin['scale']!;
      final double startTx = widget.slideForward ? tInit['translate']! : tFin['translate']!;
      final double endScale = widget.slideForward ? tFin['scale']! : tInit['scale']!;
      final double endTx = widget.slideForward ? tFin['translate']! : tInit['translate']!;

      // Use AnimatedBuilder on the same _anim that goes 0->1 for both directions.
      return ClipRect(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final t = _anim.value;
            final scale = lerpDouble(startScale, endScale, t)!;
            final tx = lerpDouble(startTx, endTx, t)!;

            // Apply translate then scale
            final mat = Matrix4.identity()
              ..translate(tx)
              ..scale(scale, scale);

            final mappedWidth = tInit['mappedWidth']!;
            return Transform(
              transform: mat,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: mappedWidth,
                height: viewportH,
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: mappedWidth,
                    height: viewportH,
                    child: widget.image,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

/// Shows an image portion (start..start+windowFraction) expanded to fill the
/// viewport, and animates that portion from `startFrom` -> `startTo`.
///
/// Example:
///   startFrom: 0.4 (40%)  windowFrom: 0.5 (40..90)
///   startTo:   0.0 (0%)   windowTo:   0.5 (0..50)
class FillWindowSlide extends StatefulWidget {
  final CommonImage image;
  final bool animate;
  final Duration duration;
  final Curve curve;

  /// initial window (visible at rest)
  final double startFrom;
  final double windowFrom;

  /// final window (where it animates to when `animate==true`)
  final double startTo;
  final double windowTo;

  const FillWindowSlide({
    super.key,
    required this.image,
    this.animate = false,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    // Defaults match your example: initially show 40..90 then animate to 0..50
    this.startFrom = 0.4,
    this.windowFrom = 0.5,
    this.startTo = 0.0,
    this.windowTo = 0.5,
  })  : assert(startFrom >= 0 && startFrom <= 1),
        assert(startTo >= 0 && startTo <= 1),
        assert(windowFrom > 0 && windowFrom <= 1),
        assert(windowTo > 0 && windowTo <= 1);

  @override
  State<FillWindowSlide> createState() => _FillWindowSlideState();
}

class _FillWindowSlideState extends State<FillWindowSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);

    // show the "from" mapping when not animating
    _ctrl.value = 0.0;

    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  @override
  void didUpdateWidget(covariant FillWindowSlide old) {
    super.didUpdateWidget(old);

    if (widget.duration != old.duration) _ctrl.duration = widget.duration;

    // animate false->true: start run
    if (widget.animate && !old.animate) _run();

    // animate true->false: stop and snap to initial (from) view
    if (!widget.animate && old.animate) {
      _ctrl.stop();
      _ctrl.value = 0.0;
    }

    // if the window parameters change while animating, restart to apply them
    if (widget.animate &&
        (widget.startFrom != old.startFrom ||
            widget.windowFrom != old.windowFrom ||
            widget.startTo != old.startTo ||
            widget.windowTo != old.windowTo)) {
      _run();
    }
  }

  void _run() {
    _ctrl
      ..stop()
      ..forward(from: 0.0);
  }

  /// Compute scale + translate so that the image portion [startFrac .. startFrac+windowFrac]
  /// is expanded to fill the viewport width.
  Map<String, double> _computeFor(double viewportW, double startFrac, double windowFrac) {
    // mappingFactor = 1.0 treats full image width as 100% == viewport width.
    const mappingFactor = 1.0;
    final mappedWidth = viewportW * mappingFactor; // base child coordinate width

    final s = startFrac.clamp(0.0, 1.0);
    final w = windowFrac.clamp(0.0001, 1.0);

    final startPx = s * mappedWidth; // child-space px where window begins
    final windowPx = (w * mappedWidth).clamp(1.0, mappedWidth);

    // scale required so that the sampled window expands to the viewport width
    final scale = viewportW / windowPx;

    // final rendered child width = mappedWidth * scale
    final childRenderWidth = mappedWidth * scale;

    // the translation we need to apply to the rendered child so the window's startPx
    // aligns with the viewport left: tx = -startPx * scale
    final translate = -startPx * scale;

    return {
      'scale': scale,
      'translate': translate,
      'mappedWidth': mappedWidth,
      'childRenderWidth': childRenderWidth,
      'windowPx': windowPx,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bc) {
      final viewportW = bc.maxWidth;
      final viewportH = bc.maxHeight;

      final tFrom = _computeFor(viewportW, widget.startFrom, widget.windowFrom);
      final tTo = _computeFor(viewportW, widget.startTo, widget.windowTo);

      return ClipRect(
        // Clip to viewport bounds to avoid overflow
        child: SizedBox(
          width: viewportW,
          height: viewportH,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final t = _anim.value;

              final curScale = lerpDouble(tFrom['scale']!, tTo['scale']!, t)!;
              final curTranslate = lerpDouble(tFrom['translate']!, tTo['translate']!, t)!;
              final curChildWidth = lerpDouble(tFrom['childRenderWidth']!, tTo['childRenderWidth']!, t)!;

              // We place the image inside a Stack and position it using a left offset (curTranslate).
              // The image is given a fixed width = curChildWidth so it renders at the proper scale.
              // Height is not forced here — the image preserves aspect ratio and its height is
              // implicitly scaled; ClipRect ensures any excess is clipped.
              return Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned(
                    left: curTranslate,
                    top: 0,
                    width: curChildWidth,
                    // Let the image determine its height from intrinsic aspect ratio.
                    child: SizedBox(
                      width: curChildWidth,
                      // Do NOT set height so the image keeps its aspect ratio.
                      child: widget.image,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

