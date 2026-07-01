import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final Color? color;
  final double? size;
  final String? semanticsLabel;

  const CommonIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.color,
    this.size,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final iconColor = color ?? colors.surface;
    final iconSize = size ?? 24.0.r;

    Widget iconWidget = Icon(
      icon,
      color: iconColor,
      size: iconSize,
      semanticLabel: semanticsLabel,
    );

    if (onPressed != null) {
      iconWidget = InkWell(
        onTap: onPressed,
        child: iconWidget,
      );
    }

    if (label != null) {
      return Semantics(
        label: label,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
