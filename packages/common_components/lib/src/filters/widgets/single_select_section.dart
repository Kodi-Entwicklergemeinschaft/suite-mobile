import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/generic_filter_model.dart';

/// Widget to render a single-select filter section
class SingleSelectSection extends StatelessWidget {
  final FilterSection section;
  final String? selectedOptionId;
  final Function(String optionId, {dynamic value}) onSelect;

  const SingleSelectSection({
    super.key,
    required this.section,
    this.selectedOptionId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section title
        Text(
          section.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),

        /// Options as chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: section.options.map((option) {
            final isSelected = selectedOptionId == option.id;
            return _buildChip(
              context: context,
              label: option.label,
              isSelected: isSelected,
              onTap: () => onSelect(option.id, value: option.value),
            );
          }).toList(),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 42.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 10.w),
              Icon(
                Icons.check,
                size: 16.sp,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
