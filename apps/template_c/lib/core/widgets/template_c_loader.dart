import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TemplateCLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double borderRadius;
  final double? height;

  const TemplateCLoader({
    super.key,
    this.size = 40.0,
    this.color,
    this.borderRadius = 0,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = Theme.of(context).colorScheme.primary;
    return Container(
      height: height ?? MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SpinKitFadingCircle(color: resolvedColor, size: size),
      ),
    );
  }
}
