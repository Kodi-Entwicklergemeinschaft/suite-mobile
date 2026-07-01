import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/search/constant/search_sort_option.dart';
import 'package:template_c/feat/search/controller/search_controller.dart';

void showSearchFilterBottomSheet(
  BuildContext context, {
  required ValueChanged<SearchSortOption> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => SearchFilterBottomSheet(onSelected: onSelected),
  );
}

class SearchFilterBottomSheet extends BaseStatelessWidget {
  const SearchFilterBottomSheet({super.key, required this.onSelected});

  final ValueChanged<SearchSortOption> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(searchControllerProvider).sortOption;
    final appColors = ref.watch(appThemeProvider).colors;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = theme.colorScheme.surface;
    final textColor = appColors.getTextColor(isDark);
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, textColor, dividerColor),
            _buildOptions(context, selected, textColor, dividerColor),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, Color dividerColor) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: CommonText(
                    titleText: 'fav_filter_title'.tr,
                    textStyle: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dividerColor.withValues(alpha: 0.3),
                  ),
                  child: Icon(Icons.close, size: 18.sp, color: textColor),
                ),
              ),
            ],
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildOptions(
    BuildContext context,
    SearchSortOption selected,
    Color textColor,
    Color dividerColor,
  ) {
    final options = [
      (SearchSortOption.newestFirst, 'fav_filter_newest_first'.tr),
      (SearchSortOption.oldestFirst, 'fav_filter_oldest_first'.tr),
      (SearchSortOption.alphabetical, 'fav_filter_alphabetical'.tr),
    ];

    return Column(
      children: options.map((entry) {
        final (option, label) = entry;
        final isSelected = selected == option;

        return InkWell(
          onTap: () {
            onSelected(option);
            context.pop();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    titleText: label,
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                _buildRadio(context, isSelected, dividerColor),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadio(BuildContext context, bool isSelected, Color dividerColor) {
    final dotColor = Theme.of(context).extension<AppTextColors>()!.normal;
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: dotColor, width: 2.w),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            )
          : null,
    );
  }
}
