import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Resolves the correct google_fonts variant family for a given font name and
/// weight, caching results for the app's lifetime so GoogleFonts.getFont is
/// called at most once per (fontName, weight) combination.
class FontResolver {
  FontResolver._();

  static final _cache = <String, String?>{};

  static String? resolve(String baseFontName, FontWeight fontWeight) {
    final key = '${baseFontName}_${fontWeight.index}';
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final family = GoogleFonts.getFont(baseFontName, fontWeight: fontWeight).fontFamily;
      return _cache[key] = family;
    } catch (_) {
      return _cache[key] = null;
    }
  }
}
