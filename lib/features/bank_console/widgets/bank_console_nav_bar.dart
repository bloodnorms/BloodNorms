// ============================================================================
// BloodNorms | bank_console_nav_bar.dart
// Bottom navigation bar for the Bank Staff Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_nav_bar.dart';

class BankConsoleNavBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;

  const BankConsoleNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppNavBar(
      currentIndex: currentTab,
      onTap: onTabSelected,
      items: const [
        NavItem(icon: Icons.water_drop_rounded, label: 'Stock'),
        NavItem(icon: Icons.check_circle_rounded, label: 'Confirm'),
        NavItem(icon: Icons.people_rounded, label: 'Expected'),
        NavItem(icon: Icons.calendar_month_rounded, label: 'Camps'),
        NavItem(icon: Icons.more_horiz_rounded, label: 'More'),
      ],
    );
  }
}
