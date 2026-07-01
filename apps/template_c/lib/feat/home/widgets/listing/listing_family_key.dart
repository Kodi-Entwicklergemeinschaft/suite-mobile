import 'package:flutter/material.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';

/// Single source of truth for generating listing provider family keys.
///
/// Every [ListingWidget] instance and every direct [listingControllerProvider]
/// call must obtain its key through this class so the generation logic lives
/// in exactly one place.
abstract final class ListingFamilyKey {
  /// Generic key — mirrors [ListingWidget._familyKey].
  ///
  /// Pattern : `{variant}` or `{variant}_{filterKey}`
  /// Example : `of(HomeScreenConstant.contentSliderV2)`
  ///           → `"content_slider_v2"`
  /// Example : `of(HomeScreenConstant.contentSliderV3, 'featured')`
  ///           → `"content_slider_v3_featured"`
  static String of(
    HomeScreenConstant variant, [
    String filterKey = '',
  ]) {
    final base = variant.value;
    return filterKey.isEmpty ? base : '${base}_$filterKey';
  }

  /// Shorthand for the standard single-day event slider used by
  /// [HomeSingleDayView] and [HomeWeekView].
  ///
  /// Example : `dayEvents('heute')`  → `"content_slider_v2_heute"`
  /// Example : `dayEvents('morgen')` → `"content_slider_v2_morgen"`
  static String dayEvents(String filterKey) =>
      of(HomeScreenConstant.contentSliderV2, filterKey);

  /// Key for the "heute" (today) slider.
  /// Result : `"content_slider_v2_heute"`
  static String get heute => dayEvents('heute');

  /// Key for the "morgen" (tomorrow) slider.
  /// Result : `"content_slider_v2_morgen"`
  static String get morgen => dayEvents('morgen');

  /// Key for a named week day slider (e.g. monday … sunday).
  /// Example : `weekDay(HomeWeekDay.friday)` → `"content_slider_v2_friday"`
  static String weekDay(HomeWeekDay day) => dayEvents(day.filterKey);

  /// Key for the "Weitere Termine" (more dates) vertical compact slider
  /// on the listing detail screen. Scoped per listing ID so each detail
  /// page gets its own isolated provider instance.
  /// Example : `moreDates('abc123')` → `"content_slider_v3_more_dates_abc123"`
  static String moreDates(String listingId) =>
      of(HomeScreenConstant.contentSliderV3, 'more_dates_$listingId');

  /// Key for the "Könnte dir auch gefallen" (similar events) horizontal slider
  /// on the listing detail screen. Scoped per listing ID.
  /// Example : `similarEvents('abc123')` → `"content_slider_v2_similar_abc123"`
  static String similarEvents(String listingId) =>
      of(HomeScreenConstant.contentSliderV2, 'similar_$listingId');

  /// Key for a "See All" screen scoped to an optional filter key.
  ///
  /// Pattern : `seeAll` or `seeAll_{filterKey}`
  /// Example : `seeAll()`         → `"seeAll"`
  /// Example : `seeAll('heute')`  → `"seeAll_heute"`
  static String seeAll([String filterKey = '']) {
    const base = 'seeAll';
    return filterKey.isEmpty ? base : '${base}_$filterKey';
  }

  /// Key for a custom date-range slider.
  /// Example : `customRange(DateTimeRange(start: 2026-03-01, end: 2026-03-07))`
  ///           → `"content_slider_v2_custom_20260301_20260307"`
  static String customRange(DateTimeRange range) {
    final from = range.start;
    final to = range.end;
    String pad(int n) => n.toString().padLeft(2, '0');
    return dayEvents(
      'custom_'
      '${from.year}${pad(from.month)}${pad(from.day)}'
      '_${to.year}${pad(to.month)}${pad(to.day)}',
    );
  }
}
