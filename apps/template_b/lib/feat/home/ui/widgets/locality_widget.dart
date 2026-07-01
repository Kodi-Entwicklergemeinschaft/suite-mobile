import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:theme/theme.dart';
import 'package:locale/localizations.dart';
import '../../controller/home_controller.dart';
import '../../data/models/home_config.dart';

class LocalityWidget extends BaseStatefulWidget {
  final String? title;
  final List<LocalityItem> items;
  final List<LocalityItem> selectedItems;
  final LocalityVariant variant;
  final int maxSelection;
  final bool hasNextPage;
  final bool isLoadingMore;
  final Function(LocalityItem)? onItemTap;
  final Function(List<LocalityItem>)? onSelectionChanged;

  const LocalityWidget({
    super.key,
    this.title,
    required this.items,
    required this.selectedItems,
    this.variant = LocalityVariant.slider,
    this.maxSelection = 3,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.onItemTap,
    this.onSelectionChanged,
  });

  @override
  ConsumerState<LocalityWidget> createState() => _LocalityWidgetState();
}

class _LocalityWidgetState extends BaseStatefulWidgetState<LocalityWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasNextPage || widget.isLoadingMore) return;
    // Trigger load when 3 card widths (103w * 3 ≈ 309) from the end
    final threshold = _scrollController.position.maxScrollExtent - 309.w;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(homeProvider.notifier).loadMoreLocalities();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null &&
              widget.variant != LocalityVariant.dropdown)
            CommonText(
              titleText: widget.title!,
              isHeader: true,
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          if (widget.title != null &&
              widget.variant != LocalityVariant.dropdown)
            SizedBox(height: 16.h),
          widget.variant == LocalityVariant.dropdown
              ? _buildDropdownVariant(context)
              : _buildSliderVariant(context),
        ],
      ),
    );
  }

  /// Slider variant - horizontal scrollable list with infinite scroll
  Widget _buildSliderVariant(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    // +1 for loading spinner at end when fetching next page
    final itemCount = widget.items.length + (widget.hasNextPage ? 1 : 0);

    return SizedBox(
      height: 126.h,
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Loading spinner card at the end
          if (index == widget.items.length) {
            return SizedBox(
              width: 48.w,
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appTheme.colors.primary,
                  ),
                ),
              ),
            );
          }

          final item = widget.items[index];
          final isSelected = widget.selectedItems.contains(item);

          return SizedBox(
            width: 103.w,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: item.name ?? '',
              hint: 'select'.tr,
              child: GestureDetector(
                onTap: () => widget.onItemTap?.call(item),
                child: ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Stack(
                      children: [
                        CommonImage(
                          imagePath: item.image ?? '',
                          width: 103.w,
                          height: 126.h,
                          fit: BoxFit.cover,
                          label: 'Locality item ${index + 1}',
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(
                                    context,
                                  ).colorScheme.scrim.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Selection indicator (star icon)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Icon(
                            isSelected ? Icons.star : Icons.star_border,
                            color: isSelected
                                ? appTheme.colors.primary
                                : appTheme.colors.surfaceLight,
                            size: 24.sp,
                          ),
                        ),
                        if (item.name != null)
                          Positioned(
                            bottom: 8.h,
                            left: 8.w,
                            right: 8.w,
                            child: CommonText(
                              titleText: item.name!,
                              textStyle: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: appTheme.colors.surfaceLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Dropdown variant - using custom MultiSelectDropdown
  Widget _buildDropdownVariant(BuildContext context) {
    final multiSelectItems = widget.items
        .map<MultiSelectItem<LocalityItem>>(
          (item) => MultiSelectItem<LocalityItem>(
            value: item,
            label: item.name ?? item.id,
          ),
        )
        .toList();

    return SizedBox(
      width: double.infinity,
      child: MultiSelectDropdown<LocalityItem>(
        items: multiSelectItems,
        width: MediaQuery.of(context).size.width - 32.w,
        hint: 'select_localities_max'.tr.replaceFirst(
          '{count}',
          '${widget.maxSelection}',
        ),
        searchHint: 'search_localities'.tr,
        noItemsFoundText: 'no_localities_found'.tr,
        maxSelection: widget.maxSelection,
        initialValues: widget.selectedItems,
        decoration: MultiSelectDecoration(
          height: 31.h,
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 5.w),
        ),
        dropdownDecoration: MultiSelectDropdownDecoration(maxHeight: 400.h),
        onSelectionChanged: (selectedValues) {
          widget.onSelectionChanged?.call(selectedValues);
        },
      ),
    );
  }
}
