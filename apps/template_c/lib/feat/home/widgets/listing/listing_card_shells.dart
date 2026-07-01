import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

// ============================================================================
// STANDARD CARD SHELL — image on top (272h), info section below
// Used by: ListingItemCard (standard), HomeActionCard (V2)
// ============================================================================

class StandardCardShell extends StatelessWidget {
  final Widget imageWidget;
  final Widget infoSection;
  final VoidCallback? onTap;

  const StandardCardShell({
    super.key,
    required this.imageWidget,
    required this.infoSection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.templateColors.surfaceBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: theme.dividerTheme.color!, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              offset: Offset(0, 8.h),
              blurRadius: 54.r,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              SizedBox(height: 8.h),
              infoSection,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// COMPACT CARD SHELL — 96×96 image left, content column right
// Used by: ListingItemCard (subcategory / V3), HomeActionCard (V3)
// ============================================================================

class CompactCardShell extends StatelessWidget {
  final Widget imageWidget;
  final Widget contentColumn;
  final VoidCallback? onTap;

  const CompactCardShell({
    super.key,
    required this.imageWidget,
    required this.contentColumn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: context.templateColors.surfaceBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerTheme.color!, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              offset: Offset(0, 8.h),
              blurRadius: 54.r,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(width: 96.w, height: 96.h, child: imageWidget),
              ),
              SizedBox(width: 12.w),
              Expanded(child: contentColumn),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED TEXT STYLES — used by info sections in both listing and action cards
// ============================================================================

class CardTitleText extends StatelessWidget {
  final String text;
  final int maxLines;

  const CardTitleText(this.text, {super.key, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return CommonText(
      titleText: text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        letterSpacing: 0.28,
      ),
    );
  }
}

class CardSubtitleText extends StatelessWidget {
  final String text;
  final int maxLines;

  const CardSubtitleText(this.text, {super.key, this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    return CommonText(
      titleText: text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13.sp,
        letterSpacing: 0.26,
        color: TemplateCColors.subHeadingGrey,
      ),
    );
  }
}
