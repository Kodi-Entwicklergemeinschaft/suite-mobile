import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final base = baseColor ?? const Color(0xFF343A40).withValues(alpha: 0.7);
    final highlight = highlightColor ?? const Color(0x80FFFFFF);

    return Semantics(
      label: 'loading_label'.tr,
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1200),
        child: child,
      ),
    );
  }
}
