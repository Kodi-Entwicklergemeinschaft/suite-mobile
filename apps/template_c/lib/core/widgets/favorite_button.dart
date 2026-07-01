import 'dart:ui';
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';

class FavoriteButton extends BaseStatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  final Color backgroundColor;
  final double size;
  final double blurSigma;
  final bool useBackdropFilter;

  const FavoriteButton({
    super.key,
    this.isFavorite = false,
    this.onTap,

    this.backgroundColor = const Color(0x33FFFFFF),
    this.size = 42,
    this.blurSigma = 12,
    this.useBackdropFilter = true,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);

    final child = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: theme.colorScheme.secondary,
            size: 22.sp,
          ),
        ),
      ),
    );

    if (!useBackdropFilter) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size / 2).r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),
      ),
    );
  }
}
