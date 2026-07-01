import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:theme/theme.dart';

class SelectThemeScreen extends BaseStatefulWidget {
  const SelectThemeScreen({super.key});

  @override
  String get screenName => RouteConstant.userSettingsTheme.name;

  @override
  ConsumerState<SelectThemeScreen> createState() => _SelectThemeScreenState();
}

class _SelectThemeScreenState extends BaseStatefulWidgetState<SelectThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeServiceProvider).mode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final inverseColor = Theme.of(context).extension<AppTextColors>()!.inverse;

    return AppScaffold(
      appBar: const CommonAppBar(showBackButton: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10.h,
          children: [
            CommonText(
              titleText: 'app_theme'.tr.toUpperCase(),
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CommonText(
                      titleText: 'bright'.tr,
                      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: inverseColor,
                          ),
                    ),
                    Switch(
                      value: isDark,
                      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) return Colors.white;
                        return Colors.grey;
                      }),
                      onChanged: (value) {
                        ref
                            .read(themeServiceProvider.notifier)
                            .toggleTheme(value);
                      },
                    ),
                    CommonText(
                      titleText: 'dark'.tr,
                      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: inverseColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}