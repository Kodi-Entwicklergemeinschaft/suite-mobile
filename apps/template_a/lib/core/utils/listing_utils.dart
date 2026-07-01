import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlUtil(String url) async {
  try {
    Uri uri;

    if (url.startsWith('tel:')) {
      uri = Uri.parse(url);
    } else if (url.startsWith('mailto:')) {
      final email = url.substring(7);
      uri = Uri(scheme: 'mailto', path: email);
    } else {
      String urlString = url;
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }
      uri = Uri.parse(urlString);
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Error launching URL: $url - $e');
  }
}

Future<void> openMapUtil(double lat, double lng) async {
  await launchUrlUtil('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
}
