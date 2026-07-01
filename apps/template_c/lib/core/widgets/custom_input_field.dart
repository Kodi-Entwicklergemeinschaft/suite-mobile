import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInputField extends StatelessWidget {
  final String labelTitle;
  final bool isRequired;
  final String hintText;
  final TextEditingController controller;
  final bool suffixIcon;
  final VoidCallback? suffixOnPressed;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    super.key,
    required this.labelTitle,
    this.isRequired = false,
    required this.hintText,
    required this.controller,
    this.suffixIcon = false,
    this.suffixOnPressed,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.focusNode,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                titleText: labelTitle,
                textStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              if (isRequired)
                CommonText(
                  titleText: "*",
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 4.h), // spacing between label and field
        /// TextField
        CommonTextField(
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType ?? TextInputType.text,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          suffixIcon: suffixIcon
              ? IconButton(
                  padding: EdgeInsets.only(left: 12.w),
                  onPressed: suffixOnPressed,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFACB5BB),
                    size: 16.sp,
                  ),
                )
              : null,
          onChanged: onChanged,
          showClearButton: false,
          obscureText: obscureText,
          controller: controller,
          hintText: hintText,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF8F8F9) : TemplateCColors.darkModeBackground,
          borderRadius: 10,

          hintFontSize: 14.sp,
          hintFontWeight: FontWeight.w500,

          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12.5),

          borderColor: const Color(0xFFEBEBEB),
        ),
      ],
    );
  }
}
