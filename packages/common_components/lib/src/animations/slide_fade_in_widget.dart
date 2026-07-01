import 'package:flutter/material.dart';

class SlideFadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const SlideFadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.offset = const Offset(0.0, 0.5),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideFadeInWidget> createState() => _SlideFadeInWidgetState();
}

class _SlideFadeInWidgetState extends State<SlideFadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
