import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feat/listing/data/models/listing_model.dart';
import 'package:intl/intl.dart';

String formatDate(String dateStr) {
  try {
    final utcDate = DateTime.parse(dateStr);
    final DateTime date = utcDate.toLocal();
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  } catch (e) {
    return dateStr;
  }
}
 
/// Format datetime string to dd.mm.yyyy hh:mm format
/// Example: "2024-01-15T14:30:00" -> "15.01.2024 14:30"
String formatDateTime(String dateStr) {
  try {
    final utcDate = DateTime.parse(dateStr);
    final DateTime date = utcDate.toLocal();
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateStr;
  }
}

Color getTagColor(String? hexColor) {
  try {
    return hexColor == null
        ? Colors.grey
        : Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  } catch (e) {
    return Colors.grey;
  }
}

/// Get date range string showing start and end dates if available
/// For events with event dates: "15.01.2026 - 31.03.2026"
/// For single day events: "15.01.2026"
/// Falls back to creation date if no event dates are available
String? getDateRange(ListingModel listing) {
  // For events with event dates
  if (listing.eventStart != null && listing.eventStart!.isNotEmpty) {
    final startDate = formatDate(listing.eventStart!);

    // If end date exists and is different from start date, show range
    if (listing.eventEnd != null && listing.eventEnd!.isNotEmpty) {
      final endDate = formatDate(listing.eventEnd!);
      if (startDate != endDate) {
        return '$startDate - $endDate';
      }
    }

    return startDate;
  }
  // Fallback to publish date only
  if (listing.publishAt != null && listing.publishAt!.isNotEmpty) {
    return formatDate(listing.publishAt!);
  }
  // Fallback to creation date
  if (listing.createdAt != null && listing.createdAt!.isNotEmpty) {
    return formatDate(listing.createdAt!);
  }

  return null;
}

/// Launch URL (phone, email, or web)
/// Handles tel:, mailto:, and https:// URIs
Future<void> launchUrlUtil(String url) async {
  try {
    Uri uri;

    // Handle phone numbers
    if (url.startsWith('tel:')) {
      uri = Uri.parse(url);
    }
    // Handle email addresses - use proper Uri construction
    else if (url.startsWith('mailto:')) {
      // Remove 'mailto:' prefix to get just the email
      final email = url.substring(7);
      uri = Uri(scheme: 'mailto', path: email);
    }
    // Handle regular URLs
    else {
      String urlString = url;
      if (!urlString.startsWith('http://') &&
          !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }
      uri = Uri.parse(urlString);
    }

    // Launch the URL without checking canLaunchUrl first
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (e) {
    debugPrint('Error launching URL: $url - $e');
  }
}
