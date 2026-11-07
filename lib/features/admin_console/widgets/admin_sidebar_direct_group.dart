// ============================================================================
// BloodNorms | admin_sidebar_direct_group.dart
// Top-Level Navigation Direct Action Items (Dashboard, Crisis Radar, Queue)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import 'admin_sidebar_direct_item.dart';

class AdminSidebarDirectGroup extends StatelessWidget {
  final String activePage;
  final bool isSidebarCompact;
  final bool isPermanent;
  final ValueChanged<String> onPageSelected;

  const AdminSidebarDirectGroup({
    super.key,
    required this.activePage,
    required this.isSidebarCompact,
    required this.isPermanent,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminSidebarDirectItem(
          id: 'dashboard',
          title: 'Dashboard Cockpit',
          icon: Icons.dashboard_rounded,
          isSelected: activePage == 'dashboard',
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onSelected: onPageSelected,
        ),
        AdminSidebarDirectItem(
          id: 'crisis_radar',
          title: 'Live Crisis Radar',
          icon: Icons.radar_rounded,
          badge: 'LIVE',
          badgeColor: BrandColors.red,
          isSelected: activePage == 'crisis_radar',
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onSelected: onPageSelected,
        ),
        AdminSidebarDirectItem(
          id: 'needs_human',
          title: 'Needs Human Queue',
          icon: Icons.notification_important_rounded,
          badge: 'CRITICAL',
          badgeColor: const Color(0xFFD97706),
          isSelected: activePage == 'needs_human',
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onSelected: onPageSelected,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Color(0xFF242731), height: 1),
        ),
      ],
    );
  }
}
