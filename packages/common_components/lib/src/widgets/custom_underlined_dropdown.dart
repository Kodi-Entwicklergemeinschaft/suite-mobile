import 'package:flutter/material.dart';
import 'common_text.dart';

class CustomUnderlinedDropdown extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isExpanded;
  final Widget? suffixIcon;

  const CustomUnderlinedDropdown({
    super.key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: isExpanded,
      dropdownColor: colors.surface,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 10,
          color: theme.hintColor,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: colors.primary,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: colors.primary,
          ),
        ),
      ),
      icon: suffixIcon,
      style: TextStyle(
        fontSize: 16,
        color: colors.onSurface,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: CommonText(
            titleText: item,
            textStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
