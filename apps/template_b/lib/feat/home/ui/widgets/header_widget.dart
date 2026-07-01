import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/theme_config/presentation/theme_data.dart';
import 'package:theme/theme.dart';

class HeaderWidget extends BaseStatelessWidget {
  final String? backgroundImage;
  final VoidCallback onMenuTap;
  final VoidCallback? onSearchTap;
  final bool showSearchBar;
  final bool showHamburgerMenu;

  const HeaderWidget({
    super.key,
    this.backgroundImage,
    required this.onMenuTap,
    this.onSearchTap,
    this.showSearchBar = true,
    this.showHamburgerMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appThemeProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final darkTheme = buildThemeData(
      colors.colors,
      Brightness.dark,
      colors.font,
    );

    return Theme(
      data: darkTheme,
      child: SliverPersistentHeader(
        pinned: true,
        delegate: SliverSearchAppBarDelegate(
          minHeight: 60.h + statusBarHeight,
          maxHeight: 250.h + statusBarHeight,
          backgroundImage: backgroundImage,
          containerColor: Theme.of(context).scaffoldBackgroundColor,
          maxBlurSigma: 10.0,
          maxLeftOffset: 20,
          maxScaleReduction: 0.1,
          onMenuPressed: showHamburgerMenu ? onMenuTap : null,
          child: _SearchBarContent(
            showSearchBar: showSearchBar,
            colors: colors,
            onSearchTap: onSearchTap,
          ),
        ),
      ),
    );
  }
}

class _SearchBarContent extends StatelessWidget {
  final bool showSearchBar;
  final AppTheme colors;
  final VoidCallback? onSearchTap;

  const _SearchBarContent({
    required this.showSearchBar,
    required this.colors,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showSearchBar)
            Container(
              decoration: BoxDecoration(
                color: colors.colors.surfaceLight.withValues(alpha: 0.5),
                border: Border.all(color: colors.colors.surfaceLight, width: 1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: SearchBarWidget(
                fillColor: Colors.transparent,
                filled: false,
                onTap: onSearchTap,
                readOnly: onSearchTap != null,
              ),
            ),
        ],
      ),
    );
  }
}
