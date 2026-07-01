import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'common_text.dart';

class InfoTile extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final IconData icon;
  final double iconSize;

  const InfoTile({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.icon = Icons.info,
    this.iconSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = backgroundColor ?? colors.surface;
    final iColor = iconColor ?? colors.onSurface;
    final tColor = textColor ?? colors.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize.r, color: iColor),
            const SizedBox(width: 12),
            Expanded(
              child: CommonText(
                titleText: text,
                maxLines: 3,
                overflow: TextOverflow.visible,
                textStyle: TextStyle(
                  color: tColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
