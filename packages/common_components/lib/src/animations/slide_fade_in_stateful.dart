import 'package:flutter/material.dart';

class SlideFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const SlideFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 0.2),
  });

  @override
  State<SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<SlideFadeIn> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _animate ? Offset.zero : widget.offset,
      curve: Curves.easeOutCubic,
      duration: widget.duration,
      child: AnimatedOpacity(
        duration: widget.duration,
        opacity: _animate ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
