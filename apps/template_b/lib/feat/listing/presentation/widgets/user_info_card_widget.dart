import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';

/// User/Organizer information card for listing detail
class UserInfoCardWidget extends StatelessWidget {
  final String? organizerName;
  final String? organizerEmail;
  final String? organizerPhone;
  final String? organizerImage;
  final VoidCallback? onTap;

  const UserInfoCardWidget({
    Key? key,
    this.organizerName,
    this.organizerEmail,
    this.organizerPhone,
    this.organizerImage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show only if organizer name exists
    if (organizerName == null || organizerName!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleContact =
        (organizerEmail != null && organizerEmail!.isNotEmpty)
        ? organizerEmail
        : organizerPhone;
    final semanticLabel = [
      organizerName,
      visibleContact,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Semantics(
          button: onTap != null,
          label: semanticLabel,
          child: GestureDetector(
            onTap: onTap,
            child: ExcludeSemantics(
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    child: organizerImage != null && organizerImage!.isNotEmpty
                        ? ClipOval(
                            child: CommonImage(
                              imagePath: organizerImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                  ),
                  SizedBox(width: 12.w),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        CommonText(
                          titleText: organizerName ?? 'Organizer',
                          textStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          // maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 4.h),

                        // Email or Phone
                        if (organizerEmail != null &&
                            organizerEmail!.isNotEmpty)
                          CommonText(
                            titleText: organizerEmail!,
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                          )
                        else if (organizerPhone != null &&
                            organizerPhone!.isNotEmpty)
                          CommonText(
                            titleText: organizerPhone!,
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
