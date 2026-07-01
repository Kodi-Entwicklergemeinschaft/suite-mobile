import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';
import 'package:template_c/feat/fav/constant/fav_filter_contant.dart';

/// Convenience wrapper for the events filter.
void showFavFilterBottomSheet(
  BuildContext context, {
  required FavSortOption selected,
  required ValueChanged<FavSortOption> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => FavFilterBottomSheet(
      title: 'fav_filter_title'.tr,
      options: [
        'fav_filter_newest_first'.tr,
        'fav_filter_oldest_first'.tr,
        'fav_filter_alphabetical'.tr,
      ],
      initialSelectedIndex: selected.index,
      onSelected: (i) => onSelected(FavSortOption.values[i]),
    ),
  );
}

/// Generic reusable filter bottom sheet.
/// Manages selection state locally; calls [onSelected] with the chosen index.
class FavFilterBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final int initialSelectedIndex;
  final ValueChanged<int> onSelected;

  const FavFilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.initialSelectedIndex,
    required this.onSelected,
  });

  @override
  State<FavFilterBottomSheet> createState() => _FavFilterBottomSheetState();
}

class _FavFilterBottomSheetState extends State<FavFilterBottomSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.extension<AppTextColors>()!.normal;
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final surfaceColor = theme.colorScheme.surface;

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
            _buildOptions(textColor),
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
                    titleText: widget.title,
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

  Widget _buildOptions(Color textColor) {
    return Column(
      children: List.generate(widget.options.length, (index) {
        final isSelected = _selectedIndex == index;
        return InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            widget.onSelected(index);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    titleText: widget.options[index],
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                _buildRadio(isSelected, textColor),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRadio(bool isSelected, Color textColor) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: textColor, width: 2.w),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor,
              ),
            )
          : null,
    );
  }
}
