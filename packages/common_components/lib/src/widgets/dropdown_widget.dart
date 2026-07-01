import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'common_text.dart';

class DropdownWidget<T> extends StatefulWidget {
  final String? label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?) onChanged;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final double borderRadius;
  final bool showBorder;
  final double? height;
  final EdgeInsets? padding;
  final Widget? suffixIcon;
  final TextStyle? textStyle;
  final Color? dropdownBackgroundColor;

  const DropdownWidget({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 4.0,
    this.showBorder = true,
    this.height,
    this.padding,
    this.suffixIcon,
    this.textStyle,
    this.dropdownBackgroundColor,
  });

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = widget.backgroundColor ?? colors.surface;
    final bColor = widget.borderColor ?? colors.primary;
    final tColor = widget.textColor ?? colors.onSurface;
    final iColor = widget.iconColor ?? colors.primary;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        border: widget.showBorder ? Border.all(color: bColor) : null,
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
      ),
      child: Padding(
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButton<T>(
          value: widget.value,
          isExpanded: true,
          underline: SizedBox.shrink(),
          icon: widget.suffixIcon ??
              Icon(Icons.arrow_drop_down, color: iColor, size: 24),
          iconSize: 24,
          style: widget.textStyle ??
              TextStyle(
                color: tColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
          items: widget.items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: CommonText(
                titleText: widget.itemLabel(item),
                textStyle: TextStyle(
                  color: tColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
