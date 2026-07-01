import 'package:locale/localizations.dart';

/// Central datetime utility for the Heidi Suite.
///
/// Covers every datetime need in the system:
///   • UTC ↔ local parsing / serialisation
///   • Pure predicates and date-math helpers
///   • All locale-translated display formatters
///
/// Call [initializeDateTimeLocalizations] once at app startup so the
/// translated weekday / month names are available.
abstract final class DateTimeHelper {
  // ─── translation key lists ────────────────────────────────────────────────

  static const _weekdayAbbrKeys = [
    'dt_weekday_abbr_mon', 'dt_weekday_abbr_tue', 'dt_weekday_abbr_wed',
    'dt_weekday_abbr_thu', 'dt_weekday_abbr_fri', 'dt_weekday_abbr_sat',
    'dt_weekday_abbr_sun',
  ];

  static const _weekdayFullKeys = [
    'dt_weekday_full_mon', 'dt_weekday_full_tue', 'dt_weekday_full_wed',
    'dt_weekday_full_thu', 'dt_weekday_full_fri', 'dt_weekday_full_sat',
    'dt_weekday_full_sun',
  ];

  static const _monthAbbrKeys = [
    'dt_month_abbr_jan', 'dt_month_abbr_feb', 'dt_month_abbr_mar',
    'dt_month_abbr_apr', 'dt_month_abbr_may', 'dt_month_abbr_jun',
    'dt_month_abbr_jul', 'dt_month_abbr_aug', 'dt_month_abbr_sep',
    'dt_month_abbr_oct', 'dt_month_abbr_nov', 'dt_month_abbr_dec',
  ];

  static const _monthFullKeys = [
    'dt_month_full_jan', 'dt_month_full_feb', 'dt_month_full_mar',
    'dt_month_full_apr', 'dt_month_full_may', 'dt_month_full_jun',
    'dt_month_full_jul', 'dt_month_full_aug', 'dt_month_full_sep',
    'dt_month_full_oct', 'dt_month_full_nov', 'dt_month_full_dec',
  ];

  // ─── UTC ↔ local parsing / serialisation ─────────────────────────────────

  /// Parses a UTC ISO-8601 string and converts to device-local time.
  /// Returns null on null input or parse failure — safe to call with any API field.
  static DateTime? parseUtcToLocal(String? iso) =>
      iso != null ? DateTime.tryParse(iso)?.toLocal() : null;

  /// Serialises a local [DateTime] to a UTC ISO-8601 string for API requests.
  /// Returns null if [dt] is null.
  static String? toUtcIsoString(DateTime? dt) => dt?.toUtc().toIso8601String();

  // ─── predicates ──────────────────────────────────────────────────────────

  /// True when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// True when [dt] is today (device-local calendar day).
  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  /// True when [dt] is tomorrow (device-local calendar day).
  static bool isTomorrow(DateTime dt) =>
      isSameDay(dt, DateTime.now().add(const Duration(days: 1)));

  /// True when [dt] is strictly before now.
  static bool isPast(DateTime dt) => dt.isBefore(DateTime.now());

  /// True when [dt] is strictly after now.
  static bool isFuture(DateTime dt) => dt.isAfter(DateTime.now());

  /// True when [dt] falls within [start]..[end] (inclusive on both ends).
  static bool isInDateRange(DateTime dt, DateTime start, DateTime end) =>
      !dt.isBefore(start) && !dt.isAfter(end);

  // ─── date-math ───────────────────────────────────────────────────────────

  /// Midnight at the start of [dt]'s calendar day.
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Last millisecond of [dt]'s calendar day.
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  // ─── locale-translated building blocks ───────────────────────────────────

  /// Abbreviated weekday name for [dt], e.g. "Mon" / "Mo".
  static String weekdayAbbr(DateTime dt) =>
      _weekdayAbbrKeys[dt.weekday - 1].tr;

  /// Full weekday name for [dt], e.g. "Monday" / "Montag".
  static String weekdayFull(DateTime dt) =>
      _weekdayFullKeys[dt.weekday - 1].tr;

  /// Abbreviated month name for [month] (1–12), e.g. "Jan" / "Mär".
  static String monthAbbr(int month) => _monthAbbrKeys[month - 1].tr;

  /// Full month name for [month] (1–12), e.g. "January" / "Januar".
  static String monthFull(int month) => _monthFullKeys[month - 1].tr;

  // ─── time / date formatters ───────────────────────────────────────────────

  /// "HH:mm" from [dt], e.g. "09:05".
  static String formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// "HH:mm – HH:mm" from a start and optional end; returns '' if [start] is null.
  static String formatEventTime(DateTime? start, [DateTime? end]) {
    if (start == null) return '';
    final s = formatTime(start);
    return end != null ? '$s – ${formatTime(end)}' : s;
  }

  /// "DD.MM.YY" short date, e.g. "12.05.26".
  static String formatShortDate(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(dt.day)}.${pad(dt.month)}.${dt.year.toString().substring(2)}';
  }

  /// "DD.MM.YYYY" full numeric date, e.g. "12.05.2026".
  static String formatFullDate(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(dt.day)}.${pad(dt.month)}.${dt.year}';
  }

  /// "YYYY-MM-DD" ISO date-only string for API query params, e.g. "2026-05-12".
  static String formatIsoDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// "Mo, 19 Jan 26" — tab-bar date label.
  static String formatTabDate(DateTime dt) {
    final year = dt.year.toString().substring(2);
    return '${weekdayAbbr(dt)}, ${dt.day} ${monthAbbr(dt.month)} $year';
  }

  /// "Monday, 09 January 2026" — full selected-date label (e.g. calendar header).
  static String formatSelectedDate(DateTime dt) =>
      '${weekdayFull(dt)}, ${dt.day.toString().padLeft(2, '0')} ${monthFull(dt.month)} ${dt.year}';

  /// "Thursday 21. March 2026" — event detail header.
  /// Returns '' if [dt] is null.
  static String formatEventDateFull(DateTime? dt) {
    if (dt == null) return '';
    return '${weekdayFull(dt)} ${dt.day}. ${monthFull(dt.month)} ${dt.year}';
  }

  /// "Until 12.05.26" / "Bis 12.05.26" — expiry label.
  /// Returns '' if [dt] is null.
  static String formatBisDate(DateTime? dt) {
    if (dt == null) return '';
    return '${'dt_bis_prefix'.tr} ${formatShortDate(dt)}';
  }

  /// "01.04 – 15.04" — compact day.month range label (no year).
  static String formatDateRangeLabel(DateTime start, DateTime end) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(start.day)}.${pad(start.month)} – ${pad(end.day)}.${pad(end.month)}';
  }

  /// "Thu. 21.5.26" for a single day, "Thu. 21.5.26 – Sat. 23.5.26" for a range.
  /// Day and month are not zero-padded (matches template_c listing display).
  /// Returns '' if [start] is null.
  static String formatEventDateRange(DateTime? start, [DateTime? end]) {
    if (start == null) return '';
    final yy = start.year.toString().substring(2);
    final startPart = '${weekdayAbbr(start)}. ${start.day}.${start.month}.$yy';
    if (end != null && !isSameDay(start, end)) {
      final endYy = end.year.toString().substring(2);
      return '$startPart – ${weekdayAbbr(end)}. ${end.day}.${end.month}.$endYy';
    }
    return startPart;
  }

  /// "Thu. 21 May, 11:00" or "Thu. 21 May, 11:00 – 20:00".
  /// Returns '' if [start] is null.
  static String formatEventDate(DateTime? start, [DateTime? end]) {
    if (start == null) return '';
    final datePart = '${weekdayAbbr(start)} ${start.day} ${monthFull(start.month)}';
    return '$datePart, ${formatEventTime(start, end)}';
  }

  /// "Sun. 27.09.26" for a single day, "Sun. 27.09.26 – Mon. 28.09.26" for a range.
  /// Day and month are zero-padded (matches poi bottom-sheet display).
  static String formatDateRange(DateTime start, [DateTime? end]) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final yy = start.year.toString().substring(2);
    final startPart =
        '${weekdayAbbr(start)}. ${pad(start.day)}.${pad(start.month)}.$yy';
    if (end != null && !isSameDay(start, end)) {
      final endYy = end.year.toString().substring(2);
      return '$startPart – ${weekdayAbbr(end)}. ${pad(end.day)}.${pad(end.month)}.$endYy';
    }
    return startPart;
  }

  /// "Today · 11:00", "Tomorrow · 11:00 Uhr", or "Mon. 3. Jan · 11:00 Uhr".
  /// Uses dt_today / dt_tomorrow and appends dt_time_suffix when non-empty.
  static String formatEventDateTime(DateTime start) {
    final String prefix;
    if (isToday(start)) {
      prefix = 'dt_today'.tr;
    } else if (isTomorrow(start)) {
      prefix = 'dt_tomorrow'.tr;
    } else {
      prefix = '${weekdayAbbr(start)}. ${start.day}. ${monthAbbr(start.month)}';
    }
    final timeSuffix = 'dt_time_suffix'.tr;
    final suffix = timeSuffix.isEmpty ? '' : ' $timeSuffix';
    return '$prefix · ${formatTime(start)}$suffix';
  }

  /// "Thursday, 16. April" or "Thursday, 16. April 2026" — waste-calendar pickup date.
  /// Accepts an ISO date string "YYYY-MM-DD".
  /// Returns '' if [iso] is null; returns the raw string if parsing fails.
  static String formatPickupDate(String? iso, {bool withYear = false}) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final year = withYear ? ' ${dt.year}' : '';
      return '${weekdayFull(dt)}, ${dt.day}. ${monthFull(dt.month)}$year';
    } catch (_) {
      return iso;
    }
  }
}
