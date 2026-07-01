import 'package:flutter/material.dart';

class OfflineNavItem {
  final String key;
  final String label;
  final String? iconUrl;
  final IconData icon;

  const OfflineNavItem({
    required this.key,
    required this.label,
    this.iconUrl,
    this.icon = Icons.extension,
  });
}
