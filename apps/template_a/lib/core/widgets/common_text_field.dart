import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

/// Custom text field widget for template_a
///
/// Usage:
/// ```dart
/// CommonTextField(
///   label: 'Email',
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.label,
    this.fillColor,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.autovalidateMode,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.hintTextColor,
    this.labelTextColor,
    this.readOnly = false,
    this.focusColor,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.autofocus = false,
    this.contentPadding,
  });

  final String label;
  final Color? fillColor;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onEditingComplete;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final Color? hintTextColor;
  final Color? labelTextColor;
  final bool readOnly;
  final Color? focusColor;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? enabled;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      textField: true,
      label: label,
      child: TextFormField(
        readOnly: readOnly,
        enabled: enabled ?? !readOnly,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        autovalidateMode: autovalidateMode,
        onEditingComplete: onEditingComplete,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        autofocus: autofocus,
        cursorColor: theme.colorScheme.secondary,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: fillColor ??theme.colorScheme.surface.withAlpha(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: focusColor ?? Colors.white,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
            backgroundColor: Colors.transparent,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: theme.textTheme.bodyMedium?.fontSize ?? 16.sp,
            overflow: TextOverflow.ellipsis,
            color: hintTextColor ?? theme.colorScheme.onPrimary,
          ),
          contentPadding: contentPadding,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: theme.textTheme.bodyMedium?.fontSize ?? 16.sp,
          overflow: TextOverflow.ellipsis,
          color: labelTextColor ?? theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
