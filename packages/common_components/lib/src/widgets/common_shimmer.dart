import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const CommonShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final colors = Theme.of(context).colorScheme;
    final base = baseColor ?? colors.surfaceContainerHighest.withValues(alpha: 0.7);
    final highlight = highlightColor ?? colors.surfaceContainerHighest.withValues(alpha: 0.9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}
