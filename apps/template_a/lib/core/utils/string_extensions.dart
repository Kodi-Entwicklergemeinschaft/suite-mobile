import 'package:flutter/material.dart';

extension StringExtensions on String? {
  bool get isNotNullAndEmpty {
    final value = this;
    return value != null && value.trim().isNotEmpty;
  }

  bool get isNullOrEmpty {
    final value = this;
    return value == null || value.trim().isEmpty;
  }

  Color get hexToColor {
    final hexString = this;
    if (hexString == null || !hexString.startsWith('#') || hexString.length != 7) {
      return Colors.transparent; 
    }
    final hexValue = hexString.substring(1);
    return Color(int.parse('FF$hexValue', radix: 16));
  }
}
