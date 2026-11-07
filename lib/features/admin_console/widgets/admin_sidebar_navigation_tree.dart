// ============================================================================
// BloodNorms | admin_sidebar_navigation_tree.dart
// Scrollable Navigation Tree Composed of Direct Items and Category Tiles
// ============================================================================

import 'package:flutter/material.dart';
import 'admin_sidebar_category_tile.dart';
import 'admin_sidebar_direct_group.dart';

class AdminSidebarNavigationTree extends StatelessWidget {
  final String activePage;
  final bool isSidebarCompact;
  final Set<String> expandedCategories;
  final ValueChanged<String> onPageSelected;
  final ValueChanged<String> onToggleCategory;
  final bool isPermanent;

  const AdminSidebarNavigationTree({
    super.key,
    required this.activePage,
    required this.isSidebarCompact,
    required this.expandedCategories,
    required this.onPageSelected,
    required this.onToggleCategory,
    required this.isPermanent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        AdminSidebarDirectGroup(
          activePage: activePage,
          isSidebarCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onPageSelected: onPageSelected,
        ),
        AdminSidebarCategoryTile(
          categoryId: 'broadcast',
          categoryTitle: 'Broadcast Center',
          categoryIcon: Icons.campaign_rounded,
          activePage: activePage,
          isExpanded: expandedCategories.contains('broadcast'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'broadcast_dispatch', 'title': 'Dispatch Broadcaster'},
            {'id': 'broadcast_audience', 'title': 'Audience & Geofence'},
            {'id': 'broadcast_history', 'title': 'Campaign History'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'voice',
          categoryTitle: 'AI Voice Studio',
          categoryIcon: Icons.record_voice_over_rounded,
          badge: 'AI',
          badgeColor: const Color(0xFF9333EA),
          activePage: activePage,
          isExpanded: expandedCategories.contains('voice'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'voice_simulator', 'title': 'Voice Simulator Sandbox'},
            {'id': 'voice_prompts', 'title': 'Prompts & Guardrails'},
            {'id': 'voice_safety', 'title': 'Safety Cap & Minutes'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'whatsapp',
          categoryTitle: 'WhatsApp Comms Hub',
          categoryIcon: Icons.chat_bubble_rounded,
          badge: 'INR',
          badgeColor: const Color(0xFF16A34A),
          activePage: activePage,
          isExpanded: expandedCategories.contains('whatsapp'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'whatsapp_bot', 'title': 'Live Assistant Bot'},
            {'id': 'whatsapp_templates', 'title': 'Template Chat Preview'},
            {'id': 'whatsapp_telecom', 'title': 'Telecom Rate Cards'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'camps',
          categoryTitle: 'Blood Camps & Drives',
          categoryIcon: Icons.event_available_rounded,
          badge: 'DRIVES',
          badgeColor: const Color(0xFF2563EB),
          activePage: activePage,
          isExpanded: expandedCategories.contains('camps'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'camps_list', 'title': 'Scheduled Drives'},
            {'id': 'camps_create', 'title': 'Schedule New Drive'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'banks',
          categoryTitle: 'Blood Centers & Stock',
          categoryIcon: Icons.local_hospital_rounded,
          activePage: activePage,
          isExpanded: expandedCategories.contains('banks'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'banks_directory', 'title': 'Connected Centers'},
            {'id': 'banks_stock', 'title': '8-Group Stock Matrix'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'donors',
          categoryTitle: 'Donors Registry',
          categoryIcon: Icons.people_rounded,
          badge: '450',
          badgeColor: const Color(0xFF7C3AED),
          activePage: activePage,
          isExpanded: expandedCategories.contains('donors'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'donors_list', 'title': 'Donors Directory'},
            {'id': 'donors_location', 'title': 'Location & Travel Caps'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'shield',
          categoryTitle: 'Hospitals & Shield',
          categoryIcon: Icons.shield_rounded,
          badge: 'FRAUD',
          badgeColor: const Color(0xFFE11D48),
          activePage: activePage,
          isExpanded: expandedCategories.contains('shield'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'hospitals_list', 'title': 'Verified Hospitals'},
            {'id': 'requester_shield', 'title': 'Requester Abuse Shield'},
            {'id': 'community_partners', 'title': 'Community Partners & NGOs'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'governance',
          categoryTitle: 'Governance & Desk',
          categoryIcon: Icons.rule_folder_rounded,
          badge: '2-EYE',
          badgeColor: const Color(0xFFD97706),
          activePage: activePage,
          isExpanded: expandedCategories.contains('governance'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'approvals_queue', 'title': 'Four-Eyes Approvals'},
            {'id': 'data_exports', 'title': 'Data Exports Engine'},
            {'id': 'dpdp_registry', 'title': 'DPDP Privacy & Erasures'},
          ],
        ),
        AdminSidebarCategoryTile(
          categoryId: 'settings',
          categoryTitle: 'Platform Settings',
          categoryIcon: Icons.settings_rounded,
          activePage: activePage,
          isExpanded: expandedCategories.contains('settings'),
          isCompact: isSidebarCompact,
          isPermanent: isPermanent,
          onToggleCategory: onToggleCategory,
          onPageSelected: onPageSelected,
          children: const [
            {'id': 'settings_killswitch', 'title': 'Master Platform Killswitch'},
            {'id': 'settings_algorithm', 'title': 'Search Ring Parameters'},
            {'id': 'settings_safety', 'title': 'Clinical Safety Desk'},
            {'id': 'settings_audit', 'title': 'Immutable Audit Logs'},
          ],
        ),
      ],
    );
  }
}
