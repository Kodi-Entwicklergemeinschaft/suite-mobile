import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonFloatingLabelDropDown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final bool isEnabled;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const CommonFloatingLabelDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.isEnabled = true,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      isExpanded: true,
      menuMaxHeight: 300.h,
      onChanged: isEnabled ? onChanged : null,
      icon: icon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 30.h,
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            overflow: TextOverflow.ellipsis,
            color: Theme.of(context).colorScheme.inverseSurface),
        floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            overflow: TextOverflow.ellipsis,
            color: Theme.of(context).colorScheme.inverseSurface),
        labelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            overflow: TextOverflow.ellipsis,
            color: Theme.of(context).colorScheme.inverseSurface),
        hintMaxLines: 1,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14.sp,
          overflow: TextOverflow.ellipsis,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 18.h,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .inverseSurface
                  .withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .inverseSurface
                  .withOpacity(0.5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .inverseSurface
                  .withOpacity(0.5)),
        ),
      ),
    );
  }
}
