import 'package:flutter/material.dart';

enum SlideDirection { left, right, up, down }

class SlideInOutWidget extends StatefulWidget {
  final Widget child;
  final bool slideIn;
  final bool animate;
  final Duration duration;
  final SlideDirection direction;
  final Curve curve;
  final double distance;

  const SlideInOutWidget({
    super.key,
    required this.child,
    this.slideIn = true,
    this.animate = true,
    this.duration = const Duration(milliseconds: 600),
    this.direction = SlideDirection.left,
    this.curve = Curves.easeInOut,
    this.distance = 1.0,
  });

  @override
  State<SlideInOutWidget> createState() => _SlideInOutWidgetState();
}

class _SlideInOutWidgetState extends State<SlideInOutWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(widget.distance, 0);
      case SlideDirection.right:
        return Offset(-widget.distance, 0);
      case SlideDirection.up:
        return Offset(0, widget.distance);
      case SlideDirection.down:
        return Offset(0, -widget.distance);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final beginOffset = widget.slideIn ? _getBeginOffset() : Offset.zero;
    final endOffset = widget.slideIn ? Offset.zero : _getBeginOffset();

    _offsetAnimation =
        Tween<Offset>(begin: beginOffset, end: endOffset).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SlideInOutWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
