import 'package:common_components/common_components.dart';
import 'package:flutter/widgets.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';

// All datetime formatting delegates to DateTimeHelper from common_components.
// nameInitials is unrelated to datetime and lives here.

/// Injects device-resolved values into [filter] based on its [deviceParams] set
/// and backward-compat [requireLatLong] / [requireEventStart] flags.
///
/// Resolution order:
///   1. deviceParams (precise — backend controls exactly which fields are sent)
///   2. requireLatLong / requireEventStart (blunt flags for non-API callers)
ListingFilterModel injectDeviceValues(
  ListingFilterModel filter,
  PreferenceManager pref,
) {
  final dp = filter.deviceParams;

  if (dp.contains('latitude')) {
    filter = filter.copyWith(latitude: pref.getDouble(StorageKeys.lat));
  }
  if (dp.contains('longitude')) {
    filter = filter.copyWith(longitude: pref.getDouble(StorageKeys.long));
  }
  if (dp.contains('radiusMeters')) {
    filter = filter.copyWith(
      radiusMeters: (pref.getDouble(StorageKeys.radius) * 1000).toInt(),
    );
  }
  if (dp.contains('eventStartFrom')) {
    filter = filter.copyWith(eventStartFrom: DateTime.now());
  }

  if (filter.requireLatLong && dp.isEmpty) {
    filter = filter.copyWith(
      latitude: pref.getDouble(StorageKeys.lat),
      longitude: pref.getDouble(StorageKeys.long),
      radiusMeters: (pref.getDouble(StorageKeys.radius) * 1000).toInt(),
    );
  }
  if (filter.requireEventStart && !dp.contains('eventStartFrom')) {
    filter = filter.copyWith(eventStartFrom: DateTime.now());
  }

  return filter;
}

/// "Mo, 19 Jan 26"
String formatTabDate(DateTime date) => DateTimeHelper.formatTabDate(date);

/// Abbreviated month name, e.g. "Mär"
String monthAbbr(int month) => DateTimeHelper.monthAbbr(month);

/// Full month name, e.g. "März"
String monthFull(int month) => DateTimeHelper.monthFull(month);

/// "Monday, 09 January 2026"
String formatSelectedDate(DateTime date) =>
    DateTimeHelper.formatSelectedDate(date);

/// "Thursday 21. March 2026"
String formatEventDateFull(DateTime? dt) =>
    DateTimeHelper.formatEventDateFull(dt);

/// "11:00 – 20:00"
String formatEventTime(DateTime? start, [DateTime? end]) =>
    DateTimeHelper.formatEventTime(start, end);

/// "Until 12.05.26"
String formatBisDate(DateTime? dt) => DateTimeHelper.formatBisDate(dt);

/// "01.04 – 15.04"
String formatDateRangeLabel(DateTime start, DateTime end) =>
    DateTimeHelper.formatDateRangeLabel(start, end);

/// "Thu. 21.5.26" or "Thu. 21.5.26 – Sat. 23.5.26"
String formatEventDateRange(DateTime? start, [DateTime? end]) =>
    DateTimeHelper.formatEventDateRange(start, end);

/// "Thu. 21 May, 11:00 – 20:00"
String formatEventDate(DateTime? start, [DateTime? end]) =>
    DateTimeHelper.formatEventDate(start, end);

/// Builds a [CommonImage] for a listing using [ListingModel.resolvedImageUrl]
/// as the primary source and [ListingModel.imageFallback] as the error fallback.
/// Centralises the hero → category-fallback → error-widget logic in one place.
Widget buildListingImage(
  ListingModel model, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  final src = model.resolvedImageUrl ?? '';
  final fallback = model.imageFallback;
  return CommonImage(
    imagePath: src,
    fit: fit,
    width: width,
    height: height,
    errorWidget: fallback != null
        ? (ctx, err, st) => CommonImage(
            imagePath: fallback,
            fit: fit,
            width: width,
            height: height,
          )
        : null,
  );
}

/// The best available date for a listing — used for badge day/month display.
/// Prefers eventStart, falls back to publishAt then createdAt.
DateTime? resolvedBadgeDate(ListingModel listing) =>
    listing.eventStart ?? listing.publishAt ?? listing.createdAt;

/// Date range string for a listing card/detail.
///
/// Priority:
///   1. eventStart (+ eventEnd if different day) → "Thu. 21.5.26" or "Thu. 21.5.26 – Sat. 23.5.26"
///   2. publishAt  → single date
///   3. createdAt  → single date
///   4. null       → caller decides whether to hide the date row
String? getDateRange(ListingModel listing) {
  if (listing.eventStart != null) {
    final range = formatEventDateRange(listing.eventStart, listing.eventEnd);
    if (range.isNotEmpty) return range;
  }
  if (listing.publishAt != null) {
    final range = formatEventDateRange(listing.publishAt);
    if (range.isNotEmpty) return range;
  }
  if (listing.createdAt != null) {
    final range = formatEventDateRange(listing.createdAt);
    if (range.isNotEmpty) return range;
  }
  return null;
}

/// Returns initials from a name, e.g. "Posthalle Würzburg" → "PW"
String nameInitials(String name) {
  final parts = name
      .trim()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
