import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:theme/theme.dart';

void showOrganizerUnsubscribeSheet(
  BuildContext context, {
  required String name,
  required String? category,
  required String? logoUrl,
  required VoidCallback onConfirmUnsubscribe,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    useRootNavigator: true,
    builder: (_) => _OrganizerUnsubscribeSheet(
      name: name,
      category: category,
      logoUrl: logoUrl,
      onConfirmUnsubscribe: onConfirmUnsubscribe,
    ),
  );
}

class _OrganizerUnsubscribeSheet extends StatelessWidget {
  final String name;
  final String? category;
  final String? logoUrl;
  final VoidCallback onConfirmUnsubscribe;

  const _OrganizerUnsubscribeSheet({
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.onConfirmUnsubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final textColor = theme.extension<AppTextColors>()!.normal;
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final initials = nameInitials(name);
    final displayInitials = initials.isNotEmpty ? initials : name[0].toUpperCase();
    final chipBg = context.templateColors.chipBg;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 15.w,
        right: 15.w,
        bottom: 24.w + bottomInset,
      ),
      child: Container(
        width: 345.w,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(36.r),
          border: Border.all(color: dividerColor, width: 1.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Avatar
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dividerColor, width: 1.w),
              ),
              child: ClipOval(
                child: hasLogo
                    ? CommonImage(
                        imagePath: logoUrl!,
                        fit: BoxFit.cover,
                        width: 64.w,
                        height: 64.w,
                      )
                    : ColoredBox(
                        color: chipBg,
                        child: Center(
                          child: CommonText(
                            titleText: displayInitials,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Name
            CommonText(
              titleText: name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
                color: textColor,
              ),
            ),

            // Category
            if (category != null && category!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              CommonText(
                titleText: category!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            SizedBox(height: 32.h),

            // Unsubscribe button
            SizedBox(
              width: 191.w,
              height: 46.h,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onConfirmUnsubscribe();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0312D),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  alignment: Alignment.center,
                  child: CommonText(
                    titleText: 'organizer_unsubscribe_confirm'.tr,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Cancel text
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: TemplateCColors.subHeadingGrey,
                  decoration: TextDecoration.underline,
                  decorationColor: TemplateCColors.subHeadingGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
