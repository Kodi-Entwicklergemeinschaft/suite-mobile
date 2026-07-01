import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/template_chip.dart';
import 'package:template_c/feat/fav/controller/fav_controller.dart';

/// A horizontal scrollable row of filter chips.
///
/// When [customChips] is provided the widget renders those chips with local
/// selection state driven by [customSelectedSlug] and [onCustomChipTap].
/// When [customChips] is null the widget reads chip data from the fav
/// controller (events mode).
class FavChipsRow extends BaseStatelessWidget {
  final VoidCallback? onCalendarTap;

  // Custom chip data (organizer mode / dummy data)
  final List<({String label, String slug})>? customChips;
  final String? customSelectedSlug;
  final ValueChanged<String>? onCustomChipTap;

  const FavChipsRow({
    super.key,
    this.onCalendarTap,
    this.customChips,
    this.customSelectedSlug,
    this.onCustomChipTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favScreenControllerProvider);
    final controller = ref.read(favScreenControllerProvider.notifier);

    final isCustom = customChips != null;
    final itemCount = isCustom ? customChips!.length : state.favCategoryList.length;

    return SizedBox(
      height: 42.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (onCalendarTap != null) ...[
              GestureDetector(
                onTap: onCalendarTap,
                child: Container(
                  width: 42.0.w,
                  height: 42.0.h,
                  padding:
                      EdgeInsets.symmetric(vertical: 11.h, horizontal: 11.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45.5.r),
                    color: context.templateColors.chipBg,
                    border: Border.all(
                      color: Theme.of(context).dividerTheme.color!,
                      width: 1.0,
                    ),
                  ),
                  child: CommonImage(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    imagePath: 'assets/svg/calendar.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              8.horizontalSpace,
            ],
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (isCustom) {
                  final item = customChips![index];
                  return TemplateChip(
                    label: item.label,
                    isActive: customSelectedSlug == item.slug,
                    onTap: () => onCustomChipTap?.call(item.slug),
                  );
                }
                final item = state.favCategoryList[index];
                return TemplateChip(
                  label: item.title ?? '',
                  isActive: state.selectedFavCategory == item.slug,
                  onTap: () async {
                    await controller.updateSelectedCategory(item.slug!);
                  },
                );
              },
              separatorBuilder: (context, index) => 8.horizontalSpace,
              itemCount: itemCount,
            ),
          ],
        ),
      ),
    );
  }
}
