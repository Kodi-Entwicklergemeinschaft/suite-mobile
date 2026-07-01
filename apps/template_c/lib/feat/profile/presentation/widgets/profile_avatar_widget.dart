import 'dart:io';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final VoidCallback onTap;

  final VoidCallback? onDeletePressed;

  final String? avatarUrl;

  final File? file;

  final bool isUploadingImage;

  const ProfileAvatarWidget({
    required this.onTap,
    this.onDeletePressed,
    this.avatarUrl,
    this.file,
    this.isUploadingImage = false,
    super.key,
  });

  bool get _isBusy => isUploadingImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        fit: StackFit.loose,

        children: [
          GestureDetector(
            onTap: _isBusy ? null : onTap,
            child: Container(
              height: 120.h,
              width: 120.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CommonImage(
                      imagePath: file != null ? file!.path : (avatarUrl ?? ''),
                      imageFile: file,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      cacheHeight: 300,
                    ),
                    if (_isBusy)
                      Container(
                        color: Colors.black26,
                        child: Center(
                          child: SizedBox(
                            width: 32.w,
                            height: 32.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (onDeletePressed != null)
          Positioned(
            top: 0,
            right: 5.w,
            child: GestureDetector(
              onTap: _isBusy ? null : onDeletePressed,
              child: CommonImage(
                imagePath: 'assets/svg/delete.svg',
                height: 24.h,
                width: 24.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
