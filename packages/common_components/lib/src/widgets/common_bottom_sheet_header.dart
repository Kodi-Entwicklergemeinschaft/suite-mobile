import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';
import 'common_text.dart';

/// Standardised header for modal bottom sheets.
///
/// Shows a centred [title], an X close button on the right, and an optional
/// back-chevron on the left (enabled via [showBackButton]).
///
/// [onClose] is called when the X button is tapped.
/// [onBack]  is called when the back button is tapped (required when
///           [showBackButton] is true).
class CommonBottomSheetHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback onClose;
  final VoidCallback? onBack;

  const CommonBottomSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.showBackButton = false,
    this.onBack,
  }) : assert(
          !showBackButton || onBack != null,
          'onBack must be provided when showBackButton is true',
        );

  @override
  Widget build(BuildContext context) {
    final textColor = AppTextColors.of(context).normal;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerTheme.color ??
        Theme.of(context).colorScheme.outlineVariant;

    return Container(
      height: 82.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Row(
        children: [
          // ── Left: back button or sizebox ──────────────────────────────
          if (showBackButton)
            GestureDetector(
              onTap: onBack,
              child: SizedBox(
                width: 42.w,
                height: 42.h,
                child: Icon(Icons.chevron_left, size: 28.sp, color: textColor),
              ),
            )
          else
             SizedBox(
                width: 42.w,
                height: 42.h,
              ),

          // ── Centre: title ─────────────────────────────────────────────
          Expanded(
            child: Center(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),

          // ── Right: close (X) button ───────────────────────────────────
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 0.875),
              ),
              child: Icon(Icons.close, size: 14.sp, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
