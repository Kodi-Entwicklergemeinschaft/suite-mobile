import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonSwitchToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? scale;

  const CommonSwitchToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoSwitch(
      applyTheme: true,
      value: value,
      onChanged: onChanged,
    );
  }
}
