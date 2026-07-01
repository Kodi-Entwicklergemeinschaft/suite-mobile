import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';
import 'common_text.dart';

enum ButtonType { normal, outline, text }

enum ButtonSize { large, small }

class AppButton extends ConsumerWidget {
  final Function()? onPressed;
  final String text;
  final TextAlign? textAlign;
  final Color? textColor;
  final Color? bgColor;
  final bool loading;
  final bool disabled;
  final ButtonType type;
  final Widget? icon;
  final MainAxisSize mainAxisSize;
  final ButtonSize size;
  final double? width;
  final double? height;
  final double borderRadius;
  final TextOverflow? textOverflow;
  final FontWeight? fontWeight;
  final double? fontSize;

  const AppButton(
    this.text, {
    super.key,
    this.textAlign,
    this.onPressed,
    this.icon,
    this.textColor,
    this.bgColor,
    this.loading = false,
    this.disabled = false,
    this.type = ButtonType.normal,
    this.mainAxisSize = MainAxisSize.min,
    this.size = ButtonSize.large,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.textOverflow,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = ref.watch(appThemeProvider);
    final fontLightColor = appTheme.colors.fontLight;

    final VoidCallback? pressCallback =
        disabled || loading || onPressed == null
            ? null
            : () {
                // Unfocus any active text field to hide keyboard
                FocusManager.instance.primaryFocus?.unfocus();
                onPressed!();
              };

    Size buttonSize = Size(width ?? 64.0.w, height ?? 38.0.h);
    if (size == ButtonSize.small) {
      buttonSize = Size(width ?? 64.0.w, height ?? 36.0.h);
    }

    Widget buttonContent = Flexible(
      child: CommonText(
        titleText: text,
        overflow: textOverflow,
        maxLines: textOverflow == TextOverflow.visible ? null : 1,
        textAlign: textAlign ?? TextAlign.center,
        textStyle: theme.textTheme.labelLarge!.copyWith(
          fontSize: fontSize ?? 14.sp,
          color: textColor ??
              ((type == ButtonType.normal)
                  ? fontLightColor
                  : colorScheme.primary),
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
    );

    if (loading) {
      buttonContent = SizedBox(
        height: 24.0.r,
        width: 24.0.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.0.w,
          color: type == ButtonType.normal
              ? colorScheme.onPrimary
              : bgColor ?? colorScheme.primary,
        ),
      );
    }

    switch (type) {
      case ButtonType.outline:
        if (icon != null) {
          return OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: buttonSize,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: pressCallback,
            icon: icon!,
            label: Row(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[buttonContent],
            ),
          );
        }
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: buttonSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: pressCallback,
          child: Row(
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[buttonContent],
          ),
        );

      case ButtonType.text:
        if (icon != null) {
          return TextButton.icon(
            onPressed: pressCallback,
            icon: icon!,
            label: Row(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[buttonContent],
            ),
          );
        }
        return TextButton(
          onPressed: pressCallback,
          child: Row(
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[buttonContent],

          ),
        );

      default:
        if (icon != null) {
          return ElevatedButton.icon(
            onPressed: pressCallback,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor ?? colorScheme.primary,
              minimumSize: buttonSize,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              disabledBackgroundColor: bgColor?.withValues(alpha: 0.5) ?? colorScheme.surface,
            ),
            icon: loading ? const SizedBox.shrink() : icon!,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[buttonContent],
            ),
          );
        }
        return ElevatedButton(
          onPressed: pressCallback,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return (bgColor ?? colorScheme.primary).withValues(alpha: 0.4);
              }
              return bgColor ?? colorScheme.primary;
            }),
            minimumSize: WidgetStateProperty.all(buttonSize),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Row(
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[buttonContent],
          ),
        );
    }
  }
}
