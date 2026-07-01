import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';

class ProfileCardWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? image;
  final String? username;
  final String? email;

  const ProfileCardWidget({
    required this.onTap,
    this.image,
    this.username,
    this.email,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = [
      username,
      email,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: ClipOval(
                      child: image != null && image!.isNotEmpty
                          ? CommonImage(
                              imagePath: image!,
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                              cacheHeight: 200,
                              loadingWidget: Center(
                                child: SizedBox(
                                  width: 28.r,
                                  height: 28.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          : Icon(Icons.person, size: 40.r),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          titleText: username ?? '-',
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        CommonText(
                          titleText: email ?? '-',
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
