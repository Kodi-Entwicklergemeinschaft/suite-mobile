import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/filter/controller/quick_filter_controller.dart';
import 'package:template_a/feat/filter/controller/quick_filter_state.dart';
import 'package:template_a/feat/filter/data/models/quick_filter_response_model.dart';

Future<List<String>?> showCategoryFilterBottomSheet({
  required BuildContext context,
  required String categorySlug,
}) {
  return showModalBottomSheet<List<String>?>(
    context: context,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    useRootNavigator: false,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _CategoryFilterSheet(categorySlug: categorySlug),
    ),
  );
}

class _CategoryFilterSheet extends BaseStatefulWidget {
  final String categorySlug;

  const _CategoryFilterSheet({required this.categorySlug});

  @override
  ConsumerState<_CategoryFilterSheet> createState() =>
      _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends BaseStatefulWidgetState<_CategoryFilterSheet> {
  final Set<String> _selectedIds = {};
  bool _isReset = false;

  @override
  void initState() {
    super.initState();
    // Restore previously applied selections
    final existing =
        ref.read(quickFilterControllerProvider(widget.categorySlug)).selectedFilterIds;
    _selectedIds.addAll(existing);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(quickFilterControllerProvider(widget.categorySlug).notifier)
          .loadFilters();
    });
  }

  void _toggle(String id, bool? value) {
    setState(() {
      value == true ? _selectedIds.add(id) : _selectedIds.remove(id);
    });
  }

  void _reset() {
    setState(() {
      _selectedIds.clear();
      _isReset = true;
    });
  }

  void _apply() {
    ref
        .read(quickFilterControllerProvider(widget.categorySlug).notifier)
        .applyFilters(_selectedIds.toList());
    Navigator.of(context).pop(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickFilterControllerProvider(widget.categorySlug));
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Semantics(
            header: true,
            child: Row(
            children: [
              Expanded(
                child: CommonText(
                  titleText: 'filter'.tr,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'reset'.tr,
                child: TextButton(
                  onPressed: _reset,
                  child: ExcludeSemantics(
                    child: CommonText(
                      titleText: 'reset'.tr,
                      textStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
          SizedBox(height: 8.h),

          // Content
          Expanded(
            child: _buildContent(state, theme),
          ),

          SizedBox(height: 10.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (_selectedIds.isEmpty && !_isReset) {
                      Navigator.pop(context);
                    } else {
                      ref
                          .read(quickFilterControllerProvider(widget.categorySlug)
                              .notifier)
                          .applyFilters(_selectedIds.toList());
                      Navigator.of(context).pop(_selectedIds.toList());
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.secondary),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    minimumSize: Size(0, 56.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: CommonText(
                    titleText: 'cancel'.tr,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_selectedIds.isEmpty && !_isReset) ? null : _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    disabledBackgroundColor: (theme.chipTheme.side?.color ?? Colors.grey).withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    minimumSize: Size(0, 56.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: CommonText(
                    titleText: 'apply'.tr,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildContent(QuickFilterState state, ThemeData theme) {
    if (state.stateConstant == StateConstant.loading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.secondary),
      );
    }
    if (state.stateConstant == StateConstant.error) {
      return Center(
        child: CommonText(
          titleText: 'error_loading'.tr,
          textStyle: theme.textTheme.bodyMedium,
        ),
      );
    }
    final groups = state.filterGroups;
    if (groups.isEmpty) {
      return Center(
        child: CommonText(
          titleText: 'no_data'.tr,
          textStyle: theme.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (_, groupIndex) {
        final group = groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.name != null)
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: CommonText(
                  titleText: group.name!,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ...group.headings.map((heading) => _buildHeading(heading, theme)),
          ],
        );
      },
    );
  }

  Widget _buildHeading(FilterHeading heading, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading.name != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
            child: CommonText(
              titleText: heading.name!,
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ...heading.filters.map((item) {
          final id = item.id ?? '';
          return CheckboxListTile(
            value: _selectedIds.contains(id),
            contentPadding: EdgeInsets.zero,
            activeColor: theme.colorScheme.secondary,
            title: CommonText(
              titleText: item.displayLabel,
              textAlign: TextAlign.start,
              textStyle: const TextStyle(fontSize: 14),
            ),
            onChanged: (value) => _toggle(id, value),
          );
        }),
        Divider(
          height: 24,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.black26,
        ),
      ],
    );
  }
}
