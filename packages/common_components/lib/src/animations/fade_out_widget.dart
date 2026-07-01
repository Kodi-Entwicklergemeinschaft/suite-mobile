import 'package:flutter/material.dart';

class FadeOutWidget extends StatefulWidget {
  final Widget child;
  final Duration fadeDuration;
  final Duration startDelay;
  final double targetOpacity;

  const FadeOutWidget({
    super.key,
    required this.child,
    this.fadeDuration = const Duration(milliseconds: 800),
    this.startDelay = const Duration(milliseconds: 0),
    this.targetOpacity = 0.0,
  });

  @override
  State<FadeOutWidget> createState() => _FadeOutWidgetState();
}

class _FadeOutWidgetState extends State<FadeOutWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: widget.targetOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.startDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
