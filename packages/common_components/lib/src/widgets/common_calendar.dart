import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';

enum CalendarSelectionMode { single, range }

class CommonCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? initialRangeStart;
  final DateTime? initialRangeEnd;
  final List<DateTime> highlightedDates;
  final Map<DateTime, List<Color>>? events;
  final void Function(DateTime date)? onDateSelected;
  final void Function(DateTime start, DateTime? end)? onRangeChanged;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final CalendarSelectionMode selectionMode;
  final bool showButtons;
  final bool isLineGrid;
  final Color? selectedDayColor;

  const CommonCalendar({
    super.key,
    this.initialDate,
    this.initialRangeStart,
    this.initialRangeEnd,
    this.highlightedDates = const [],
    this.events,
    this.onDateSelected,
    this.onRangeChanged,
    this.cancelLabel = 'calendar_cancel',
    this.confirmLabel = 'calendar_confirm_range',
    this.onCancel,
    this.onConfirm,
    this.selectionMode = CalendarSelectionMode.range,
    this.showButtons = true,
    this.isLineGrid = false,
    this.selectedDayColor,
  });

  /// Shows the calendar as a dialog. Returns the selected [DateTime] for
  /// [CalendarSelectionMode.single], or a [DateTimeRange] for
  /// [CalendarSelectionMode.range]. Returns `null` if cancelled.
  static Future<T?> show<T>(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? initialRangeStart,
    DateTime? initialRangeEnd,
    List<DateTime> highlightedDates = const [],
    Map<DateTime, List<Color>>? events,
    String cancelLabel = 'calendar_cancel',
    String confirmLabel = 'calendar_confirm_range',
    CalendarSelectionMode selectionMode = CalendarSelectionMode.range,
  }) {
    DateTime? selectedDate = initialDate;
    DateTime? rangeStart = initialRangeStart;
    DateTime? rangeEnd = initialRangeEnd;

    return showDialog<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: CommonCalendar(
          initialDate: initialDate,
          initialRangeStart: initialRangeStart,
          initialRangeEnd: initialRangeEnd,
          highlightedDates: highlightedDates,
          events: events,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          selectionMode: selectionMode,
          onDateSelected: (date) => selectedDate = date,
          onRangeChanged: (start, end) {
            rangeStart = start;
            rangeEnd = end;
          },
          onCancel: () => Navigator.of(ctx).pop(null),
          onConfirm: () {
            if (selectionMode == CalendarSelectionMode.single) {
              Navigator.of(ctx).pop(selectedDate as T?);
            } else {
              if (rangeStart != null) {
                // Single date selected → treat as same-day range
                final end = rangeEnd ?? rangeStart!;
                Navigator.of(ctx)
                    .pop(DateTimeRange(start: rangeStart!, end: end) as T?);
              } else {
                Navigator.of(ctx).pop(null);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  State<CommonCalendar> createState() => _CommonCalendarState();
}

class _CommonCalendarState extends State<CommonCalendar> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
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
    final now = DateTime.now();
    _selectedDate = widget.initialDate;
    _rangeStart = widget.initialRangeStart;
    _rangeEnd = widget.initialRangeEnd;
    _displayedMonth = DateTime(
      (widget.initialDate ?? widget.initialRangeStart ?? now).year,
      (widget.initialDate ?? widget.initialRangeStart ?? now).month,
    );
    _pickerYear = _displayedMonth.year;
  }

  List<DateTime> _buildCalendarDays() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final daysInPrevMonth = DateTime(year, month, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon=0, Sun=6

    final List<DateTime> days = [];

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

  bool _isCurrentMonth(DateTime date) =>
      date.month == _displayedMonth.month &&
      date.year == _displayedMonth.year;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart =
        DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
    final normalizedEnd =
        DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day);
    return normalizedDate.isAfter(normalizedStart) &&
        normalizedDate.isBefore(normalizedEnd);
  }

  bool _isRangeEndpoint(DateTime date) =>
      _isSameDay(date, _rangeStart) || _isSameDay(date, _rangeEnd);

  void _onDayTapped(DateTime date) {
    if (widget.selectionMode == CalendarSelectionMode.single) {
      setState(() => _selectedDate = date);
      widget.onDateSelected?.call(date);
    } else {
      setState(() {
        if (_rangeStart == null ||
            (_rangeStart != null && _rangeEnd != null)) {
          _rangeStart = date;
          _rangeEnd = null;
        } else if (date.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = date;
        } else {
          _rangeEnd = date;
        }
      });
      widget.onRangeChanged?.call(_rangeStart!, _rangeEnd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final days = _buildCalendarDays();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark, colorScheme),
          SizedBox(height: 16.h),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showingPicker
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWeekdayRow(colorScheme),
                if (widget.isLineGrid) const Divider(),
                SizedBox(height: 12.h),
                _buildDaysGrid(days, colorScheme),
                if (widget.showButtons) ...[
                  SizedBox(height: 24.h),
                  _buildButtons(colorScheme),
                ],
              ],
            ),
            secondChild: _buildMonthYearPicker(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme colorScheme) {
    final monthLabel =
        '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

    return Row(
      children: [
        if (!_showingPicker)
          _ArrowButton(
            isPrev: true,
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: () => setState(() {
              _displayedMonth = DateTime(
                _displayedMonth.year,
                _displayedMonth.month - 1,
              );
            }),
          )
        else
          SizedBox(width: 44.r),
        SizedBox(width: 12.w),
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
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: _showingPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.r,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        if (!_showingPicker)
          _ArrowButton(
            isPrev: false,
            isDark: isDark,
            colorScheme: colorScheme,
            onTap: () => setState(() {
              _displayedMonth = DateTime(
                _displayedMonth.year,
                _displayedMonth.month + 1,
              );
            }),
          )
        else
          SizedBox(width: 44.r),
      ],
    );
  }

  Widget _buildMonthYearPicker(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Year navigation row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ArrowButton(
              isPrev: true,
              isDark: Theme.of(context).brightness == Brightness.dark,
              colorScheme: colorScheme,
              onTap: () => setState(() => _pickerYear--),
            ),
            Text(
              '$_pickerYear',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            _ArrowButton(
              isPrev: false,
              isDark: Theme.of(context).brightness == Brightness.dark,
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
            final isSelected = index + 1 == _displayedMonth.month &&
                _pickerYear == _displayedMonth.year;
            return GestureDetector(
              onTap: () => setState(() {
                _displayedMonth = DateTime(_pickerYear, index + 1);
                _showingPicker = false;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _monthNames[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid(
    List<DateTime> days,
    ColorScheme colorScheme,
  ) {
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)));
    }

    return Column(
      children: weeks.map((week) {
        return Container(
          padding: EdgeInsets.only(bottom: 8.h,top: 1.h),
          decoration: BoxDecoration(
            border: widget.isLineGrid?Border(bottom: BorderSide(color: Theme.of(context).dividerColor)):null,
          ),
          child: Row(
            children: week
                .map((date) => Expanded(
                      child: _buildDayCell(date, colorScheme),
                    ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    ColorScheme colorScheme,
  ) {
    final isCurrentMonth = _isCurrentMonth(date);
    final isToday = _isToday(date);
    final isSelected = widget.selectionMode == CalendarSelectionMode.single
        ? _isSameDay(date, _selectedDate)
        : _isRangeEndpoint(date);
    final isInRange = widget.selectionMode == CalendarSelectionMode.range &&
        _isInRange(date);
    
    final hasHighlight = widget.highlightedDates.any((d) => _isSameDay(d, date));
    final dayEvents = <Color>[];
    if (widget.events != null) {
      widget.events!.forEach((key, value) {
        if (_isSameDay(key, date)) {
          dayEvents.addAll(value);
        }
      });
    }

    Color? bgColor;
    Color? borderColor;
    const double borderWidth = 1.5;
    Color textColor;

    if (isSelected) {
      bgColor = widget.selectedDayColor ?? colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday && !isInRange) {
      textColor = colorScheme.primary;
    } else if (isInRange) {
      bgColor = colorScheme.primaryContainer.withAlpha(50);
      borderColor = colorScheme.primary;
      textColor = colorScheme.primary;
    } else if (!isCurrentMonth) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      textColor = colorScheme.onSurface;
    }

    final isBold = isSelected || hasHighlight || dayEvents.isNotEmpty;

    final hasDot = dayEvents.isNotEmpty || (hasHighlight);

    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTapped(date) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: borderColor != null
                    ? Border.all(color: borderColor, width: borderWidth)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.r),
          // Fixed-height dot row keeps all cells the same height
          SizedBox(
            height: 5.r,

            child: hasDot
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (dayEvents.isEmpty && hasHighlight)
                        _buildDot(colorScheme.primary),
                      ...dayEvents.map((color) => _buildDot(color)),
                    ],
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.r),
      width: 5.r,
      height: 5.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildButtons(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onCancel,
            child: Text(
              widget.cancelLabel.tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onConfirm,
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(100.r),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.confirmLabel.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceVariant.withOpacity(0.3),
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
