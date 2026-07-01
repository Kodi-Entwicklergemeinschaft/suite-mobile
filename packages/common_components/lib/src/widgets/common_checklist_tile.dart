import 'package:flutter/material.dart';
import 'common_text.dart';

class CommonChecklistTile extends StatelessWidget {
  final bool value;
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? checkColor;
  final Color? checkBoxFillColor;
  final Color? borderColor;
  final Color? iconColor;

  const CommonChecklistTile({
    super.key,
    required this.value,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.checkColor,
    this.checkBoxFillColor,
    this.borderColor,
    this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    final txtColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final chkColor = checkColor ?? Theme.of(context).colorScheme.primary;
    final fillColor = checkBoxFillColor ?? chkColor;
    final bdrColor = borderColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _checkbox(chkColor, fillColor, bdrColor),
            const SizedBox(width: 12),
            Expanded(
              child: CommonText(
                titleText: text,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.visible,
                textStyle: TextStyle(
                  color: txtColor,
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

  Widget _checkbox(Color checkColor, Color fillColor, Color borderColor) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: value ? fillColor : Colors.transparent,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: value
          ? Icon(
              Icons.check,
              size: 16,
              color: iconColor,
            )
          : null,
    );
  }
}
