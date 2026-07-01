import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/feat/filter/controller/date_filter_controller.dart';
import 'package:theme/theme.dart';

Future<Map<String, DateTime?>?> showDateRangeFilterBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<Map<String, DateTime?>?>(
    context: context,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    useRootNavigator: false,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7 - kBottomNavigationBarHeight,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const _DateRangeFilterSheet(),
    ),
  );
}

class _DateRangeFilterSheet extends BaseStatefulWidget {
  const _DateRangeFilterSheet();

  @override
  ConsumerState<_DateRangeFilterSheet> createState() =>
      _DateRangeFilterSheetState();
}

class _DateRangeFilterSheetState extends BaseStatefulWidgetState<_DateRangeFilterSheet> {
  DateTime? _start;
  DateTime? _end;
  int? _quickChipIndex;
  bool _isReset = false;
  final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final existing = ref.read(dateFilterControllerProvider);
    _start = existing.startDate;
    _end = existing.endDate;
    _quickChipIndex = _detectChipIndex(_start, _end);
  }

  int? _detectChipIndex(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final now = DateTime.now();
    final startDate = DateTime(start.year, start.month, start.day);
    final today = DateTime(now.year, now.month, now.day);
    if (startDate != today) return null;

    final endDate = DateTime(end.year, end.month, end.day);
    final in7 = DateTime(now.year, now.month, now.day + 7);
    final in30 = DateTime(now.year, now.month, now.day + 30);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    if (endDate == in7) return 1;
    if (endDate == in30) return 2;
    if (endDate == monthEnd) return 3;
    return null;
  }

  String _display(DateTime? d) => d == null ? 'not_set'.tr : _fmt.format(d);

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: now,
      lastDate: _end ?? DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _quickChipIndex = null;
        _start = picked;
        if (_end != null && _start!.isAfter(_end!)) _end = null;
      });
    }
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? _start ?? now,
      firstDate: _start ?? now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _quickChipIndex = null;
        _end = _endOfDay(picked);
        if (_start != null && _end!.isBefore(_start!)) _start = null;
      });
    }
  }

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  void _apply() {
    ref.read(dateFilterControllerProvider.notifier).updateRange(_start, _end);
    Navigator.of(context).pop({'start': _start, 'end': _end});
  }

  void _reset() {
    ref.read(dateFilterControllerProvider.notifier).reset();
    setState(() {
      _start = null;
      _end = null;
      _quickChipIndex = null;
      _isReset = true;
    });
  }

  bool get _canApply => _start != null || _end != null || _isReset || _quickChipIndex != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.extension<AppTextColors>()?.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 16.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Semantics(
                  header: true,
                  child: Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        titleText: 'f_by_date'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
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
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 17.sp,
                              color: theme.colorScheme.secondary,
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

                // Start date
                Semantics(
                  button: true,
                  label: '${'start_date'.tr}: ${_display(_start)}',
                  hint: 'select'.tr,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ExcludeSemantics(
                      child: CommonIcon(
                        icon: Icons.event,
                        color: textColor,
                        label: 'start_date'.tr,
                      ),
                    ),
                    title: CommonText(
                      titleText: '${'start_date'.tr},',
                      overflow: TextOverflow.ellipsis,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 20.sp,
                        color: textColor,
                      ),
                    ),
                    subtitle: CommonText(
                      titleText: _display(_start),
                      overflow: TextOverflow.ellipsis,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18.sp,
                        color: textColor,
                      ),
                    ),
                    trailing: ExcludeSemantics(
                      child: TextButton(
                        onPressed: _pickStart,
                        child: CommonText(
                          titleText: 'select'.tr,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18.sp,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onTap: _pickStart,
                  ),
                ),

                // End date
                Semantics(
                  button: true,
                  label: '${'end_date'.tr}: ${_display(_end)}',
                  hint: 'select'.tr,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ExcludeSemantics(
                      child: CommonIcon(
                        icon: Icons.event_note,
                        color: textColor,
                        label: 'end_date'.tr,
                      ),
                    ),
                    title: CommonText(
                      titleText: '${'end_date'.tr},',
                      overflow: TextOverflow.ellipsis,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 20.sp,
                        color: textColor,
                      ),
                    ),
                    subtitle: CommonText(
                      titleText: _display(_end),
                      overflow: TextOverflow.ellipsis,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18.sp,
                        color: textColor,
                      ),
                    ),
                    trailing: ExcludeSemantics(
                      child: TextButton(
                        onPressed: _pickEnd,
                        child: CommonText(
                          titleText: 'select'.tr,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18.sp,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onTap: _pickEnd,
                  ),
                ),

                SizedBox(height: 8.h),
                CommonText(
                  titleText: '${'quick_ranges'.tr}:',
                  overflow: TextOverflow.ellipsis,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),

                // Quick chips
                Wrap(
                  spacing: 16.w,
                  runSpacing: 4.h,
                  children: [
                    _chip(label: 'l_7d'.tr, index: 1, onSelect: () {
                      _start = DateTime.now();
                      _end = _endOfDay(DateTime.now().add(const Duration(days: 7)));
                    }),
                    _chip(label: 'l_30d'.tr, index: 2, onSelect: () {
                      _start = DateTime.now();
                      _end = _endOfDay(DateTime.now().add(const Duration(days: 30)));
                    }),
                    _chip(label: 't_month'.tr, index: 3, onSelect: () {
                      final now = DateTime.now();
                      _start = DateTime(now.year, now.month, 1);
                      _end = _endOfDay(DateTime(now.year, now.month + 1, 0));
                    }),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),

        // Buttons
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: _canApply ? _apply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    disabledBackgroundColor: (theme.chipTheme.side?.color ?? Colors.grey).withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    minimumSize: Size(0, 56.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: CommonText(
                    titleText: 'apply'.tr,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required int index,
    required VoidCallback onSelect,
  }) {
    final selected = _quickChipIndex == index;
    final theme = Theme.of(context);
    final textColors = theme.extension<AppTextColors>();

    return ChoiceChip(
      checkmarkColor: selected
          ? textColors?.inverse
          : textColors?.normal,
      label: CommonText(
        titleText: label,
        overflow: TextOverflow.ellipsis,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 18.sp,
          color: selected ? textColors?.inverse : textColors?.normal,
        ),
      ),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _quickChipIndex = index;
          onSelect();
        });
      },
    );
  }
}
