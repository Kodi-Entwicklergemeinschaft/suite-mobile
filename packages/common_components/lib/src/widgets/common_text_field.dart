import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/locale.dart';

class CommonTextField extends StatefulWidget {
  final String? label;
  final Color? fillColor;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final Color? hintTextColor;
  final Color? labelTextColor;
  final bool readOnly;
  final Color? focusColor;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final int maxLines;
  final int minLines;
  final InputDecoration? decoration;
  final bool filled;
  final bool showBorder;
  final Color? borderColor;
  final double borderRadius;
  final bool isDense;
  final EdgeInsets? contentPadding;
  final bool showClearButton;
  final Iterable<String>? autofillHints;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final double? labelFontSize;
  final double? hintFontSize;
  final FontWeight? labelFontWeight;
  final FontWeight? hintFontWeight;
  final Color? textColor;
  final Color? cursorColor;

  const CommonTextField({
    super.key,
    this.label,
    this.fillColor,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.hintTextColor,
    this.labelTextColor,
    this.readOnly = false,
    this.focusColor,
    this.onChanged,
    this.hintText,
    this.maxLines = 1,
    this.minLines = 1,
    this.decoration,
    this.filled = false,
    this.showBorder = true,
    this.borderColor,
    this.borderRadius = 5,
    this.isDense = true,
    this.contentPadding,
    this.showClearButton = true,
    this.autofillHints,
    this.onTap,
    this.onSubmitted,
    this.labelFontSize,
    this.hintFontSize,
    this.labelFontWeight,
    this.hintFontWeight,
    this.textColor,
    this.cursorColor,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  Widget? _buildSuffixWidget() {
    final widgets = <Widget>[];

    // Add custom suffix icon if provided (e.g., password visibility)
    if (widget.suffixIcon != null) {
      widgets.add(widget.suffixIcon!);
    }

    // Add clear button if enabled, not read-only, and text exists
    if (widget.showClearButton &&
        !widget.readOnly &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      widgets.add(
        GestureDetector(
          onTap: () {
            widget.controller!.clear();
            if (widget.onChanged != null) {
              widget.onChanged!('');
            }
            setState(() {});
          },
          child: Icon(Icons.clear, size: 20.r, color: widget.textColor ?? Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    if (widgets.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...widgets,
        SizedBox(width: 12.w),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = widget.fillColor ?? colors.surface;
    final txtColor = widget.textColor ?? colors.onSurface;
    final hintColor =
        widget.hintTextColor ?? colors.onSurface.withValues(alpha: 0.6);
    final labelColor = widget.labelTextColor ?? colors.inverseSurface;
    final fcColor = widget.focusColor ?? colors.primary;
    final bColor = widget.borderColor ?? colors.inverseSurface.withOpacity(0.5);

    final borderRadius = BorderRadius.circular(widget.borderRadius.r);
    final focusedBorderRadius = BorderRadius.circular(widget.borderRadius.r);

    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide:
          widget.showBorder ? BorderSide(color: bColor) : BorderSide.none,
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: focusedBorderRadius,
      borderSide: !widget.showBorder
          ? BorderSide.none
          : widget.focusColor != null
              ? BorderSide(color: fcColor)
              : BorderSide(color: bColor),
    );

    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide:
          widget.showBorder ? BorderSide(color: bColor) : BorderSide.none,
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide:
          widget.showBorder ? BorderSide(color: bColor) : BorderSide.none,
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide:
          widget.showBorder ? BorderSide(color: colors.error) : BorderSide.none,
    );

    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: widget.showBorder
          ? BorderSide(color: colors.error, width: 2.w)
          : BorderSide.none,
    );

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUnfocus,
      cursorColor: widget.cursorColor ?? colors.secondary,
      validator: widget.validator != null
          ? (value) {
              final result = widget.validator!(value);
              return result?.tr;
            }
          : null,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      textAlignVertical: TextAlignVertical.center,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      cursorHeight: (12.0 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(12.0, 40.0),
      style: TextStyle(color: txtColor),
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            filled: widget.filled,
            fillColor: bgColor,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixWidget(),
            border: border,
            enabledBorder: enabledBorder,
            disabledBorder: disabledBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: focusedErrorBorder,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(
              color: labelColor,
              fontWeight: widget.labelFontWeight ?? FontWeight.w700,
              fontSize: widget.labelFontSize ?? 20.sp,
            ),
            hintStyle: TextStyle(
              color: hintColor,
              fontWeight: widget.hintFontWeight ?? FontWeight.w300,
              fontSize: widget.hintFontSize ?? 14.sp,
            ),
            isDense: widget.isDense,
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 18.h,
                ),
            errorMaxLines: 3,
          ),
    );
  }
}
