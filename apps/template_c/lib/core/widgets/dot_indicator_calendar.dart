import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class DotIndicatorCalendar extends BaseStatefulWidget {
  /// Dates that will show a dot indicator below the day number.
  final List<DateTime> dotDates;

  /// Color of the dot indicators. Defaults to pink.
  final Color dotColor;

  /// Called when the user taps a date in the current month.
  final void Function(DateTime date)? onDateTap;

  /// Pre-selected date shown on first render.
  final DateTime? initialDate;

  /// Background color of the selected day circle. Defaults to colorScheme.primary.
  final Color? selectedDayColor;

  /// Called whenever the displayed month changes (arrows or month picker).
  /// Provides the first and last day of the new month.
  final void Function(DateTime monthStart, DateTime monthEnd)? onMonthChange;

  const DotIndicatorCalendar({
    super.key,
    this.dotDates = const [],
    this.dotColor = const Color(0xFFE8A0C0),
    this.onDateTap,
    this.initialDate,
    this.selectedDayColor,
    this.onMonthChange,
  });

  @override
  ConsumerState<DotIndicatorCalendar> createState() =>
      _DotIndicatorCalendarState();
}

class _DotIndicatorCalendarState extends BaseStatefulWidgetState<DotIndicatorCalendar> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  bool _showingPicker = false;
  late int _pickerYear;

  List<String> get _weekdays => [
    'calendar_weekday_mo'.tr,
    'calendar_weekday_tu'.tr,
    'calendar_weekday_we'.tr,
    'calendar_weekday_th'.tr,
    'calendar_weekday_fr'.tr,
    'calendar_weekday_sa'.tr,
    'calendar_weekday_su'.tr,
  ];

  List<String> get _monthNames => [
    'calendar_month_jan'.tr,
    'calendar_month_feb'.tr,
    'calendar_month_mar'.tr,
    'calendar_month_apr'.tr,
    'calendar_month_may'.tr,
    'calendar_month_jun'.tr,
    'calendar_month_jul'.tr,
    'calendar_month_aug'.tr,
    'calendar_month_sep'.tr,
    'calendar_month_oct'.tr,
    'calendar_month_nov'.tr,
    'calendar_month_dec'.tr,
  ];

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(base.year, base.month);
    _selectedDate = widget.initialDate;
    _pickerYear = _displayedMonth.year;
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

  List<DateTime> _buildCalendarDays() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final daysInPrevMonth = DateTime(year, month, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon = 0

    final days = <DateTime>[];

    for (int i = startOffset - 1; i >= 0; i--) {
      days.add(DateTime(year, month - 1, daysInPrevMonth - i));
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }
    final remainder = days.length % 7;
    if (remainder != 0) {
      for (int i = 1; i <= 7 - remainder; i++) {
        days.add(DateTime(year, month + 1, i));
      }
    }
    return days;
  }

  bool _isCurrentMonth(DateTime d) =>
      d.month == _displayedMonth.month && d.year == _displayedMonth.year;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasDot(DateTime date) =>
      widget.dotDates.any((d) => _isSameDay(d, date));

  void _changeMonth(DateTime newMonth) {
    setState(() => _displayedMonth = newMonth);
    final start = DateTime(newMonth.year, newMonth.month, 1, 0, 0, 0);
    final end = DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59);
    widget.onMonthChange?.call(start, end);
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _buildCalendarDays();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(colorScheme, isDark),
        SizedBox(height: 12.h),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _showingPicker
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeekdayRow(colorScheme),
              SizedBox(height: 12.h),

              const Divider(height: 1, thickness: 1),
              SizedBox(height: 6.h),
              _buildDaysGrid(days, colorScheme),
            ],
          ),
          secondChild: _buildMonthYearPicker(colorScheme, isDark),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    final label =
        '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 24.h,
        bottom: 24.h,
      ),
      child: Row(
        children: [
          if (!_showingPicker)
            _ArrowButton(
              isPrev: true,
              isDark: isDark,
              colorScheme: colorScheme,
              onTap: () => _changeMonth(
                DateTime(_displayedMonth.year, _displayedMonth.month - 1),
              ),
            )
          else
            SizedBox(width: 44.r),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _showingPicker = !_showingPicker;
                _pickerYear = _displayedMonth.year;
              }),
              child: Container(
                height: 44.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.templateColors.chipBg,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color!,
                    width: 1,
                  ),
                ),
                child: CommonText(
                  titleText: label,
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (!_showingPicker)
            _ArrowButton(
              isPrev: false,
              isDark: isDark,
              colorScheme: colorScheme,
              onTap: () => _changeMonth(
                DateTime(_displayedMonth.year, _displayedMonth.month + 1),
              ),
            )
          else
            SizedBox(width: 44.r),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker(ColorScheme colorScheme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Year navigation row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ArrowButton(
              isPrev: true,
              isDark: isDark,
              colorScheme: colorScheme,
              onTap: () => setState(() => _pickerYear--),
            ),
            CommonText(
              titleText: '$_pickerYear',
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            _ArrowButton(
              isPrev: false,
              isDark: isDark,
              colorScheme: colorScheme,
              onTap: () => setState(() => _pickerYear++),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // 4x3 month grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (_, index) {
            final isSelected =
                index + 1 == _displayedMonth.month &&
                _pickerYear == _displayedMonth.year;
            return GestureDetector(
              onTap: () {
                _showingPicker = false;
                _changeMonth(DateTime(_pickerYear, index + 1));
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: CommonText(
                  titleText: _monthNames[index],
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildWeekdayRow(ColorScheme colorScheme) {
    return Row(
      children: _weekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: CommonText(
                  titleText: day,
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid(List<DateTime> days, ColorScheme colorScheme) {
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)));
    }

    return Column(
      children: weeks
          .map(
            (week) => Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: week
                    .map(
                      (date) =>
                          Expanded(child: _buildDayCell(date, colorScheme)),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayCell(DateTime date, ColorScheme colorScheme) {
    // Hide dates that overflow into the next month
    if (date.month != _displayedMonth.month && date.isAfter(_displayedMonth)) {
      return const SizedBox.shrink();
    }

    final isCurrentMonth = _isCurrentMonth(date);
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isToday(date);
    final showDot = _hasDot(date);

    Color textColor;
    Color? bgColor;

    if (isSelected) {
      bgColor = widget.selectedDayColor ?? colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      textColor = colorScheme.primary;
    } else if (!isCurrentMonth) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      textColor = colorScheme.onSurface;
    }

    final isBold = isSelected || isToday || showDot;

    return GestureDetector(
      onTap: isCurrentMonth
          ? () {
              setState(() => _selectedDate = date);
              widget.onDateTap?.call(date);
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: CommonText(
              titleText: '${date.day}',
              textStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 3.r),
          SizedBox(
            height: 5.r,
            child: showDot
                ? Center(
                    child: Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: widget.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Arrow button ────────────────────────────────────────────────────────────

class _ArrowButton extends StatelessWidget {
  final bool isPrev;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.isPrev,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: context.templateColors.chipBg,
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPrev ? Icons.chevron_left : Icons.chevron_right,
          size: 20.r,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
