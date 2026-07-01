import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

class HomeHeaderImage extends StatelessWidget {
  final String imageUrl;
  final String? logoUrl;
  final VoidCallback? onHamburgerTap;

  const HomeHeaderImage({
    super.key,
    required this.imageUrl,
    this.logoUrl,
    this.onHamburgerTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.elliptical(40.w, 12.h),
        bottomRight: Radius.elliptical(40.w, 12.h),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 240.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CommonImage(
                imagePath: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 240.h,
                label: 'home_header_banner_label'.tr,
                cacheWidth: (MediaQuery.of(context).size.width *
                        MediaQuery.of(context).devicePixelRatio)
                    .round(),
                cacheHeight:
                    (240.h * MediaQuery.of(context).devicePixelRatio).round(),
              )
            else
              Container(color: Theme.of(context).colorScheme.primary),
            // Gradient overlay — only when image is present, excluded from semantics
            if (hasImage)
              ExcludeSemantics(child: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final shadowColor = isDark
                      ? Colors.black.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.85);
                  final statusBarHeight = MediaQuery.of(context).padding.top;
                  final fadeEnd = ((statusBarHeight * 2.2) / 240.h).clamp(0.0, 1.0);
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [shadowColor, Colors.transparent],
                        stops: [0.0, fadeEnd],
                      ),
                    ),
                  );
                },
              )),
            // Hamburger always on left when present
            if (onHamburgerTap != null)
              Positioned(
                top: 36.h,
                left: 8.w,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: onHamburgerTap,
                    icon: const Icon(Icons.menu, color: Colors.white),
                    iconSize: 50.h,
                    tooltip: 'menu_label'.tr,
                  ),
                ),
              ),
            // Logo: right when hamburger present, left when alone
            if (logoUrl != null && logoUrl!.isNotEmpty)
              Positioned(
                top: 50.h,
                left: onHamburgerTap == null ? 16.w : null,
                right: onHamburgerTap != null ? 16.w : null,
                child: ClipOval(
                  child: CommonImage(
                    imagePath: logoUrl!,
                    height: 68.h,
                    width: 68.h,
                    fit: BoxFit.cover,
                    label: 'app_logo_label'.tr,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
