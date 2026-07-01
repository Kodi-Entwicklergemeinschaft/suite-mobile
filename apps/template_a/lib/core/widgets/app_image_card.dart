import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_a/core/utils/template_a_colors.dart';

/// A full-bleed image card with optional top tag and bottom title/subtitle overlays.
///
/// Shared by the Discover screen and Sub-Service screen.
/// Pass only what you need — everything beyond [imageUrl] is optional.
class AppImageCard extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final VoidCallback? onTap;

  // ── Shadow ──────────────────────────────────────────────────────────────
  final double shadowOpacity;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  // ── Bottom gradient overlay ──────────────────────────────────────────────
  final bool showBottomGradient;

  // ── Top-left tag / label ─────────────────────────────────────────────────
  final String? tagText;
  final Color? tagBgColor;
  final IconData? tagIcon;
  final String? tagIconUrl;

  /// How far from the top of the card the tag starts.
  /// Pass an already-scaled value (e.g. [16.h]).
  /// Defaults to [16.h] when null.
  final double? tagTopOffset;

  /// Rounded corners for the tag container.
  /// Defaults to topRight + bottomRight (8.r) when null.
  final BorderRadius? tagBorderRadius;

  /// Max fraction of screen width the tag may occupy. Default 0.88.
  final double tagMaxWidthFraction;

  /// Raw sp value for the tag label. Applied as [tagFontSize].sp internally.
  final double tagFontSize;

  // ── Bottom title chip ────────────────────────────────────────────────────
  final String? titleText;
  final Color? titleBgColor;

  // ── Bottom subtitle text ─────────────────────────────────────────────────
  final String? subtitleText;

  const AppImageCard({
    super.key,
    required this.imageUrl,
    this.height,
    this.onTap,
    this.shadowOpacity = 0.12,
    this.shadowBlurRadius = 8.0,
    this.shadowOffset = const Offset(0, 3),
    this.showBottomGradient = true,
    this.tagText,
    this.tagBgColor,
    this.tagIcon,
    this.tagIconUrl,
    this.tagTopOffset,
    this.tagBorderRadius,
    this.tagMaxWidthFraction = 0.88,
    this.tagFontSize = 16,
    this.titleText,
    this.titleBgColor,
    this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = height ?? (screenWidth / 1.4);
    final effectiveTagTopOffset = tagTopOffset ?? 16.h;
    final effectiveTagBorderRadius = tagBorderRadius ??
        BorderRadius.circular(6.r);

    final semanticLabel = [titleText, tagText, subtitleText]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Semantics(
      button: onTap != null,
      label: semanticLabel.isNotEmpty ? semanticLabel : null,
      child: GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: imageUrl.isNotEmpty
                      ? CommonImage(
                          imagePath: imageUrl,
                          fit: BoxFit.cover,
                          label: tagText ?? titleText ?? '',
                        )
                      : Container(
                          color: tagBgColor ?? TemplateAColors.primary,
                        ),
                ),

                // Bottom gradient overlay
                if (showBottomGradient)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: cardHeight * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top-left tag
                if (tagText != null && tagText!.isNotEmpty)
                  Positioned(
                    top: effectiveTagTopOffset,
                    left: 0,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * tagMaxWidthFraction,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: effectiveTagBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tagIconUrl != null && tagIconUrl!.isNotEmpty) ...[
                            CommonImage(
                              imagePath: tagIconUrl!,
                              height: 22.h,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 8.w),
                          ] else if (tagIcon != null) ...[
                            CommonIcon(
                              icon: tagIcon!,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 5.w),
                          ],
                          Flexible(
                            fit: FlexFit.loose,
                            child: CommonText(
                              titleText: tagText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: tagFontSize.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom title + subtitle
                if (titleText != null || subtitleText != null)
                  Positioned(
                    bottom: 12.h,
                    left: 0,
                    right: 40.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (titleText != null && titleText!.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * tagMaxWidthFraction,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: titleBgColor ?? Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.r),
                                bottomRight: Radius.circular(8.r),
                              ),
                            ),
                            child: CommonText(
                              titleText: titleText!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (subtitleText != null && subtitleText!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * tagMaxWidthFraction,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.r),
                                bottomRight: Radius.circular(8.r),
                              ),
                            ),
                            child: CommonText(
                              titleText: subtitleText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
