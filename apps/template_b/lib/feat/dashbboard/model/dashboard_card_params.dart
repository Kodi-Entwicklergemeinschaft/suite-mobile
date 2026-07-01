import 'package:flutter/material.dart';

class DashboardCardParams {
  String imagePath;
  Color? color;
  String text;
  void Function() onTap;
  DashboardCardParams({
    required this.imagePath,
    this.color,
    required this.onTap,
    required this.text
  });
}
