import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import '../widgets/app_snackbar.dart';

/// Adds a single event to the device calendar using [device_calendar].
///
/// Unlike the [add_2_calendar] approach this writes directly into a calendar
/// the user selects, so the event lands without opening a separate app UI.
///
/// - Requests `calendarFullAccess` permission before proceeding.
/// - Presents a bottom-sheet calendar picker when the device has more than
///   one writable calendar.
/// - Guards against duplicates by embedding `EventID:<id>` in the description
///   and scanning the chosen calendar before creating.
///
/// [eventId]     – stable identifier for the event (used for dedup).
/// [title]       – event title shown in the calendar.
/// [startDate]   – event start (local time).
/// [endDate]     – event end (local time); falls back to [startDate] if null.
/// [location]    – optional venue / address string.
/// [description] – optional event notes; `EventID:<eventId>` is appended.
///
/// Returns `true` when the event was created, `false` otherwise.
Future<bool> addEventToDeviceCalendar({
  required BuildContext context,
  required String eventId,
  required String title,
  required DateTime startDate,
  DateTime? endDate,
  String? location,
  String? description,
}) async {
  log('[DeviceCalendar] addEventToDeviceCalendar — "$title"');

  final plugin = DeviceCalendarPlugin();
  // ── 1. Permission ──────────────────────────────────────────────────────────
  final hasPermission = await plugin.hasPermissions();
  log('[DeviceCalendar] hasPermissions: ${hasPermission.data}');

  if (hasPermission.data != true) {
    final requestResult = await plugin.requestPermissions();
    log('[DeviceCalendar] requestPermissions result: isSuccess=${requestResult.isSuccess}, data=${requestResult.data}');

    if (requestResult.data != true) {
      log('[DeviceCalendar] Permission denied — opening app settings');
      if (context.mounted) {
        AppSnackBar.showWarning(context, 'calendar_permission_required'.tr);
      }
      await openAppSettings();
      return false;
    }
  }

  // iOS 17+ needs a short delay after permission grant
  await Future<void>.delayed(const Duration(milliseconds: 300));

  // ── 2. Retrieve writable calendars ────────────────────────────────────────
  final calendarsResult = await plugin.retrieveCalendars();
  if (!calendarsResult.isSuccess ||
      calendarsResult.data == null ||
      calendarsResult.data!.isEmpty) {
    log('[DeviceCalendar] No calendars found');
    if (context.mounted) {
      AppSnackBar.showWarning(context, 'no_data'.tr);
    }
    return false;
  }

  final writableCalendars =
      calendarsResult.data!.where((c) => c.isReadOnly == false).toList();

  if (writableCalendars.isEmpty) {
    log('[DeviceCalendar] No writable calendars');
    if (context.mounted) {
      AppSnackBar.showWarning(context, 'no_data'.tr);
    }
    return false;
  }

  // ── 3. Let user pick a calendar ───────────────────────────────────────────
  if (!context.mounted) return false;

  final Calendar? targetCalendar = writableCalendars.length == 1
      ? writableCalendars.first
      : await _showCalendarPickerSheet(context, writableCalendars);

  if (targetCalendar == null) {
    log('[DeviceCalendar] User cancelled calendar selection');
    return false;
  }

  log('[DeviceCalendar] Target calendar: ${targetCalendar.name}');

  // ── 4. Duplicate check ────────────────────────────────────────────────────
  final searchStart = startDate.subtract(const Duration(days: 1));
  final searchEnd = (endDate ?? startDate).add(const Duration(days: 1));

  final eventsResult = await plugin.retrieveEvents(
    targetCalendar.id,
    RetrieveEventsParams(startDate: searchStart, endDate: searchEnd),
  );

  if (eventsResult.isSuccess && eventsResult.data != null) {
    final alreadyExists = eventsResult.data!.any(
      (e) => e.description?.contains('EventID:$eventId') ?? false,
    );
    if (alreadyExists) {
      log('[DeviceCalendar] Duplicate — event already in calendar');
      if (context.mounted) {
        AppSnackBar.showWarning(context, 'calendar_duplicate'.tr);
      }
      return false;
    }
  }

  // ── 5. Create event ───────────────────────────────────────────────────────
  final effectiveEnd = endDate ?? startDate;
  final fullDescription =
      '${description?.isNotEmpty == true ? '$description\n' : ''}EventID:$eventId';

  final event = Event(
    targetCalendar.id,
    title: title,
    description: fullDescription,
    start: TZDateTime.from(startDate, local),
    end: TZDateTime.from(effectiveEnd, local),
    location: location,
  );

  final createResult = await plugin.createOrUpdateEvent(event);
  log('[DeviceCalendar] Create result: isSuccess=${createResult?.isSuccess}, '
      'data=${createResult?.data}, errors=${createResult?.errors}');

  if (createResult?.isSuccess == true && createResult?.data != null) {
    log('[DeviceCalendar] ✓ Event created with id: ${createResult!.data}');
    if (context.mounted) {
      AppSnackBar.showSuccess(context, 'calendar_event_added'.tr);
    }
    return true;
  }

  log('[DeviceCalendar] ✗ Failed to create event');
  if (context.mounted) {
    AppSnackBar.showError(context, 'error'.tr);
  }
  return false;
}

/// Convenience wrapper that accepts raw nullable ISO-8601 strings from an API
/// model (e.g. `"2026-03-26T18:00:00.000Z"`) and delegates to
/// [addEventToDeviceCalendar].
///
/// Returns `false` and shows a [SnackBar] when [eventStart] is missing or
/// cannot be parsed.
Future<bool> addEventToDeviceCalendarFromStrings({
  required BuildContext context,
  required String eventId,
  required String title,
  String? eventStart,
  String? eventEnd,
  String? location,
  String? description,
}) async {
  final start = eventStart != null ? DateTime.tryParse(eventStart) : null;

  if (start == null) {
    if (context.mounted) {
      AppSnackBar.showWarning(context, 'calendar_no_event_date'.tr);
    }
    return false;
  }

  final end = (eventEnd != null && eventEnd.isNotEmpty)
      ? DateTime.tryParse(eventEnd) ?? start
      : start;

  return await addEventToDeviceCalendar(
    context: context,
    eventId: eventId,
    title: title,
    startDate: start.toLocal(),
    endDate: end.toLocal(),
    location: location,
    description: description,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<Calendar?> _showCalendarPickerSheet(
  BuildContext context,
  List<Calendar> calendars,
) {
  return showModalBottomSheet<Calendar>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'calendar_picker_title'.tr,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ...calendars.map(
              (cal) => ListTile(
                leading: cal.color != null
                    ? CircleAvatar(
                        backgroundColor: Color(cal.color!),
                        radius: 10,
                      )
                    : const Icon(Icons.calendar_today_outlined),
                title: Text(cal.name ?? ''),
                subtitle:
                    cal.accountName != null ? Text(cal.accountName!) : null,
                onTap: () => Navigator.of(ctx).pop(cal),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
