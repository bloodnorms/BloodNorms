// ============================================================================
// BloodNorms | admin_sidebar.dart
// Untitled UI Expandable Nested Sidebar Navigation (#121316 Deep Charcoal Dark)
// Modular Widget Composing Header, Category Tiles, and User Footer
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import 'admin_sidebar_category_tile.dart';
import 'admin_sidebar_direct_item.dart';
import 'admin_sidebar_footer.dart';
import 'admin_sidebar_header.dart';

class AdminSidebar extends StatelessWidget {
  final String activePage;
  final bool isSidebarCompact;
  final Set<String> expandedCategories;
  final ValueChanged<String> onPageSelected;
  final VoidCallback onToggleCompact;
  final ValueChanged<String> onToggleCategory;
  final bool isPermanent;

  const AdminSidebar({
    super.key,
    required this.activePage,
    required this.isSidebarCompact,
    required this.expandedCategories,
    required this.onPageSelected,
    required this.onToggleCompact,
    required this.onToggleCategory,
    required this.isPermanent,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isSidebarCompact ? 68.0 : 256.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF121316),
        border: Border(right: BorderSide(color: Color(0xFF22242B), width: 1.5)),
      ),
      child: Column(
        children: [
          AdminSidebarHeader(
            isSidebarCompact: isSidebarCompact,
            onToggleCompact: onToggleCompact,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
            ),
          ),
          AdminSidebarFooter(
            isSidebarCompact: isSidebarCompact,
            onPageSelected: onPageSelected,
          ),
        ],
      ),
    );
  }
}
