// ============================================================================
// BloodNorms | admin_sidebar.dart
// Untitled UI Expandable Nested Sidebar Navigation (#121316 Deep Charcoal Dark)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
          // 1. Top Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Color(0x44E52E2E), blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  ),
                ),
                if (!isSidebarCompact) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BloodNorms OS',
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'admin.bloodnorms.org',
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onToggleCompact,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.unfold_more_rounded, color: Color(0xFF9CA3AF), size: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Search Input (Untitled UI ⌘K Pill)
          if (!isSidebarCompact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C23),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF282B37)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, size: 15, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search actions...  ⌘K',
                        style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),

          // 3. Hierarchical Expandable Navigation Tree
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildDirectItem(
                  context: context,
                  id: 'dashboard',
                  title: 'Dashboard Cockpit',
                  icon: Icons.dashboard_rounded,
                ),
                _buildDirectItem(
                  context: context,
                  id: 'crisis_radar',
                  title: 'Live Crisis Radar',
                  icon: Icons.radar_rounded,
                  badge: 'LIVE',
                  badgeColor: BrandColors.red,
                ),
                _buildDirectItem(
                  context: context,
                  id: 'needs_human',
                  title: 'Needs Human Queue',
                  icon: Icons.notification_important_rounded,
                  badge: 'CRITICAL',
                  badgeColor: const Color(0xFFD97706),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFF242731), height: 1),
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'broadcast',
                  categoryTitle: 'Broadcast Center',
                  categoryIcon: Icons.campaign_rounded,
                  children: const [
                    {'id': 'broadcast_dispatch', 'title': 'Dispatch Broadcaster'},
                    {'id': 'broadcast_audience', 'title': 'Audience & Geofence'},
                    {'id': 'broadcast_history', 'title': 'Campaign History'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'voice',
                  categoryTitle: 'AI Voice Studio',
                  categoryIcon: Icons.record_voice_over_rounded,
                  badge: 'AI',
                  badgeColor: const Color(0xFF9333EA),
                  children: const [
                    {'id': 'voice_simulator', 'title': 'Voice Simulator Sandbox'},
                    {'id': 'voice_prompts', 'title': 'Prompts & Guardrails'},
                    {'id': 'voice_safety', 'title': 'Safety Cap & Minutes'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'whatsapp',
                  categoryTitle: 'WhatsApp Comms Hub',
                  categoryIcon: Icons.chat_bubble_rounded,
                  badge: 'INR',
                  badgeColor: const Color(0xFF16A34A),
                  children: const [
                    {'id': 'whatsapp_bot', 'title': 'Live Assistant Bot'},
                    {'id': 'whatsapp_templates', 'title': 'Template Chat Preview'},
                    {'id': 'whatsapp_telecom', 'title': 'Telecom Rate Cards'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'camps',
                  categoryTitle: 'Blood Camps & Drives',
                  categoryIcon: Icons.event_available_rounded,
                  badge: 'DRIVES',
                  badgeColor: const Color(0xFF2563EB),
                  children: const [
                    {'id': 'camps_list', 'title': 'Scheduled Drives'},
                    {'id': 'camps_create', 'title': 'Schedule New Drive'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'banks',
                  categoryTitle: 'Blood Centers & Stock',
                  categoryIcon: Icons.local_hospital_rounded,
                  children: const [
                    {'id': 'banks_directory', 'title': 'Connected Centers'},
                    {'id': 'banks_stock', 'title': '8-Group Stock Matrix'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'donors',
                  categoryTitle: 'Donors Registry',
                  categoryIcon: Icons.people_rounded,
                  badge: '450',
                  badgeColor: const Color(0xFF7C3AED),
                  children: const [
                    {'id': 'donors_list', 'title': 'Donors Directory'},
                    {'id': 'donors_location', 'title': 'Location & Travel Caps'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'shield',
                  categoryTitle: 'Hospitals & Shield',
                  categoryIcon: Icons.shield_rounded,
                  badge: 'FRAUD',
                  badgeColor: const Color(0xFFE11D48),
                  children: const [
                    {'id': 'hospitals_list', 'title': 'Verified Hospitals'},
                    {'id': 'requester_shield', 'title': 'Requester Abuse Shield'},
                    {'id': 'community_partners', 'title': 'Community Partners & NGOs'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'governance',
                  categoryTitle: 'Governance & Desk',
                  categoryIcon: Icons.rule_folder_rounded,
                  badge: '2-EYE',
                  badgeColor: const Color(0xFFD97706),
                  children: const [
                    {'id': 'approvals_queue', 'title': 'Four-Eyes Approvals'},
                    {'id': 'data_exports', 'title': 'Data Exports Engine'},
                    {'id': 'dpdp_registry', 'title': 'DPDP Privacy & Erasures'},
                  ],
                ),
                _buildCategory(
                  context: context,
                  categoryId: 'settings',
                  categoryTitle: 'Platform Settings',
                  categoryIcon: Icons.settings_rounded,
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

          // 4. Bottom User Profile Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF22242B))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: BrandColors.redTint,
                  child: const Text('SA', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.red, fontSize: 12)),
                ),
                if (!isSidebarCompact) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siva (Super Admin)',
                          style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                        ),
                        Text(
                          'siva@arkiolabs.com',
                          style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 10, color: Color(0xFF9CA3AF)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF), size: 18),
                    color: const Color(0xFF1E2028),
                    onSelected: (val) {
                      if (val == 'settings') onPageSelected('settings_algorithm');
                      if (val == 'killswitch') onPageSelected('settings_killswitch');
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'profile', child: Text('View Profile (Super Admin)', style: TextStyle(color: Colors.white, fontSize: 12))),
                      PopupMenuItem(value: 'settings', child: Text('Algorithm Settings', style: TextStyle(color: Colors.white, fontSize: 12))),
                      PopupMenuItem(value: 'killswitch', child: Text('Master Killswitch', style: TextStyle(color: BrandColors.red, fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectItem({
    required BuildContext context,
    required String id,
    required String title,
    required IconData icon,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = activePage == id;

    if (isSidebarCompact) {
      return Tooltip(
        message: title,
        preferBelow: false,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF9CA3AF), size: 18),
            onPressed: () {
              onPageSelected(id);
              if (!isPermanent) Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onPageSelected(id);
            if (!isPermanent) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 17, color: isSelected ? Colors.white : const Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                      color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? BrandColors.red).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? BrandColors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory({
    required BuildContext context,
    required String categoryId,
    required String categoryTitle,
    required IconData categoryIcon,
    String? badge,
    Color? badgeColor,
    required List<Map<String, String>> children,
  }) {
    final isExpanded = expandedCategories.contains(categoryId);
    final hasActiveChild = children.any((c) => c['id'] == activePage);

    if (isSidebarCompact) {
      return Tooltip(
        message: categoryTitle,
        preferBelow: false,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: hasActiveChild ? const Color(0xFF1F222B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(categoryIcon, color: hasActiveChild ? Colors.white : const Color(0xFF9CA3AF), size: 18),
            onPressed: () {
              onToggleCategory(categoryId);
            },
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onToggleCategory(categoryId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
            child: Row(
              children: [
                Icon(categoryIcon, size: 17, color: hasActiveChild ? Colors.white : const Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryTitle,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: hasActiveChild ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                      color: hasActiveChild ? Colors.white : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? BrandColors.red).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? BrandColors.red,
                      ),
                    ),
                  ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 18),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFF282B37), width: 1.5)),
            ),
            child: Column(
              children: children.map((child) {
                final id = child['id']!;
                final title = child['title']!;
                final isSelected = activePage == id;

                return Container(
                  margin: const EdgeInsets.only(left: 8, bottom: 2, top: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        onPageSelected(id);
                        if (!isPermanent) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? BrandColors.red : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 11.5,
                                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
