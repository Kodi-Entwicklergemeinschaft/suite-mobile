import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import '../models/generic_filter_model.dart';
import '../providers/generic_filter_provider.dart';
import 'single_select_section.dart';
import 'multi_select_section.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/app_button.dart';

/// Generic filter page that can be reused across features
///
/// Usage:
/// ```dart
/// GenericFilterPage(
///   config: filterConfig,
///   onApply: (state) {
///     // Handle filter application
///     ref.read(listingProvider.notifier).applyFilters(state);
///   },
/// )
/// ```
class GenericFilterPage extends ConsumerWidget {
  /// Filter configuration defining sections and options
  final GenericFilterConfig config;

  /// Callback when filters are applied
  /// Receives the current filter state
  final Function(GenericFilterState) onApply;

  /// Optional callback when clear is pressed
  final VoidCallback? onClear;

  /// Optional initial state for the filters
  final GenericFilterState? initialState;

  const GenericFilterPage({
    super.key,
    required this.config,
    required this.onApply,
    this.onClear,
    this.initialState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterState = ref.watch(genericFilterProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(
          title: 'filter'.tr,
          showBackButton: true,
          backgroundColor: theme.colorScheme.primary,
          titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          /// Filter sections
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: config.sections.map((section) {
                  return _buildSection(context, ref, filterState, section);
                }).toList(),
              ),
            ),
          ),

          /// Bottom action buttons
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  /// Clear button
                  Expanded(
                    child: AppButton(
                      'clear_filter'.tr,
                      onPressed: () {
                        ref.read(genericFilterProvider.notifier).clearAll();
                        onClear?.call();
                      },
                      type: ButtonType.outline,
                      height: 38.h,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  /// Apply button
                  Expanded(
                    child: AppButton(
                      'apply_filter'.tr,
                      onPressed: () {
                        onApply(filterState);
                        context.pop(filterState);
                      },
                      type: ButtonType.normal,
                      height: 38.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    GenericFilterState filterState,
    FilterSection section,
  ) {
    final notifier = ref.read(genericFilterProvider.notifier);

    switch (section.type) {
      case FilterType.singleSelect:
        final selectedId = filterState.getSelection(section.id) as String?;
        return SingleSelectSection(
          section: section,
          selectedOptionId: selectedId,
          onSelect: (optionId, {value}) => notifier.selectOption(section.id, optionId, value: value),
        );

      case FilterType.multiSelect:
        final selectedIds =
            (filterState.getSelection(section.id) as List<String>?) ?? [];
        return MultiSelectSection(
          section: section,
          selectedOptionIds: selectedIds,
          onToggle: (optionId) => notifier.toggleOption(section.id, optionId),
        );

      case FilterType.dateRange:
        // DateRange filter placeholder - to be implemented
        return const SizedBox.shrink();
    }
  }
}
