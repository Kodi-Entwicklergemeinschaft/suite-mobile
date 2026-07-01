import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Prewarms [DefaultCacheManager]'s on-disk cache so remote images render
/// offline on a later render. The same cache is shared by [CachedNetworkImage]
/// and [CommonImage]'s SVG network branch, so precaching here benefits both.
///
/// All methods are fire-and-forget: failures are logged via [debugPrint] and
/// swallowed so callers don't need a try/catch.
class ImagePrecacheHandler {
  const ImagePrecacheHandler._();

  /// Downloads [url] into the disk cache. No-op for null, empty, or non-HTTP
  /// URLs (assets, file paths).
  static void precache(String? url) {
    if (!_isCacheable(url)) return;
    DefaultCacheManager().getSingleFile(url!).catchError((e) {
      debugPrint('ImagePrecacheHandler.precache failed ($url): $e');
      return File('');
    });
  }

  /// Batch variant — deduplicates URLs before prewarming.
  static void precacheAll(Iterable<String?> urls) {
    final seen = <String>{};
    for (final url in urls) {
      if (!_isCacheable(url) || !seen.add(url!)) continue;
      precache(url);
    }
  }

  static bool _isCacheable(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}
