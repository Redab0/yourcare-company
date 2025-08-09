// lib/components/custom_bottom_nav.dart

import 'package:flutter/material.dart';

/// A single tab in the bottom navigation bar.
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  const NavItem(
      {required this.label,
      required this.icon,
      required this.path,
      required this.activeIcon});
}

/// A bottom nav that builds itself from a list of [NavItem]s.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// The tabs to display.
  final List<NavItem> items;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
      backgroundColor: theme.scaffoldBackgroundColor,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
