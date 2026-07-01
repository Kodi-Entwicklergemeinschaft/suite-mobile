import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String? iconString;
  final String label;

  BottomNavItem({
    required this.icon,
    this.iconString,
    required this.label,
  });
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = backgroundColor ?? colors.surface;
    final selColor = selectedColor ?? colors.primary;

    return BottomNavigationBar(
      backgroundColor: bgColor,
      selectedItemColor: selColor,
      unselectedItemColor: colors.onSurface.withValues(alpha: 0.6),
      currentIndex: currentIndex,
      onTap: onTap,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
