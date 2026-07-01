import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:theme/theme.dart';
import 'common_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final TextStyle? titleTextStyle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backButtonColor;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleTextStyle,
    this.showBackButton = true,
    this.onBackPressed,
    this.backButtonColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? appTheme.colors.fontLight : appTheme.colors.fontDark;

    return AppBar(
      actionsIconTheme: IconThemeData(color: iconColor),
      title: titleWidget ??
          (title != null
              ? CommonText(
                  titleText: title!,
                  textStyle: titleTextStyle ??
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                        color: foregroundColor ?? iconColor,
                      ),
                )
              : null),
      centerTitle: centerTitle,
      actions: actions,
      actionsPadding: EdgeInsets.only(right: 8.w),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  onPressed: onBackPressed ?? () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: backButtonColor ?? iconColor,
                  ),
                )
              : null),
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

// sliver app bar version
class CommonSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final double elevation;
  final TextStyle? titleTextStyle;
  final VoidCallback? onBackPressed;
  final Clip clipBehavior;

  const CommonSliverAppBar({
    super.key,
    this.title,
    this.flexibleSpace,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.expandedHeight = 250,
    this.pinned = true,
    this.floating = false,
    this.elevation = 0,
    this.titleTextStyle,
    this.onBackPressed,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      elevation: elevation,
      clipBehavior: clipBehavior,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      title: title != null
          ? CommonText(
              titleText: title!,
              textStyle: titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                    color: foregroundColor ?? theme.colorScheme.onSurface,
                  ),
            )
          : null,
      leading: leading ??
          GestureDetector(
            onTap: onBackPressed ?? () => context.pop(),
            child: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
      actions: actions,
      flexibleSpace: flexibleSpace,
      surfaceTintColor: Colors.transparent,
    );
  }
}
