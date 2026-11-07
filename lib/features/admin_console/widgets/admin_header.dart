// ============================================================================
// BloodNorms | admin_header.dart
// Top Breadcrumb & Status Bar with Superhero Quick Actions
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminHeader extends StatelessWidget {
  final String activePage;
  final VoidCallback onQuickActions;

  const AdminHeader({
    super.key,
    required this.activePage,
    required this.onQuickActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations > ${getPageBreadcrumb(activePage)}',
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 12,
                color: BrandColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              getPageTitle(activePage),
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BrandColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: BrandColors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Live Sync: Connected (2s)',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onQuickActions,
              icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Superhero Actions',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String getPageBreadcrumb(String pageId) {
    if (pageId.startsWith('broadcast')) return 'Broadcast Center > ${getPageTitle(pageId)}';
    if (pageId.startsWith('voice')) return 'AI Voice Studio > ${getPageTitle(pageId)}';
    if (pageId.startsWith('whatsapp')) return 'WhatsApp Comms Hub > ${getPageTitle(pageId)}';
    if (pageId.startsWith('camps')) return 'Blood Camps > ${getPageTitle(pageId)}';
    if (pageId.startsWith('banks')) return 'Blood Centers > ${getPageTitle(pageId)}';
    if (pageId.startsWith('donors')) return 'Donors Registry > ${getPageTitle(pageId)}';
    if (pageId.startsWith('hospitals') || pageId.startsWith('requester') || pageId.startsWith('community')) {
      return 'Hospitals & Shield > ${getPageTitle(pageId)}';
    }
    if (pageId.startsWith('approvals') || pageId.startsWith('data') || pageId.startsWith('dpdp')) {
      return 'Governance > ${getPageTitle(pageId)}';
    }
    if (pageId.startsWith('settings')) return 'Platform Settings > ${getPageTitle(pageId)}';
    return getPageTitle(pageId);
  }

  static String getPageTitle(String pageId) {
    switch (pageId) {
      case 'dashboard': return 'Dashboard Cockpit';
      case 'crisis_radar': return 'Live Crisis Radar';
      case 'needs_human': return 'Needs Human Queue';
      case 'broadcast_dispatch': return 'Dispatch Regional Broadcast';
      case 'broadcast_audience': return 'Audience & Suppression Inspector';
      case 'broadcast_history': return 'Campaign History & Delivery Logs';
      case 'voice_simulator': return 'Interactive Voice Simulator';
      case 'voice_prompts': return 'Prompts & Clinical Guardrails';
      case 'voice_safety': return 'Daily Safety Cap & Minutes';
      case 'whatsapp_bot': return 'Live Assistant Bot Status';
      case 'whatsapp_templates': return 'Template Builder & Chat Preview';
      case 'whatsapp_telecom': return 'Telecom Rate Cards & Spend';
      case 'camps_list': return 'Scheduled Blood Drives';
      case 'camps_create': return 'Schedule New Drive';
      case 'banks_directory': return 'Connected Blood Centers';
      case 'banks_stock': return 'Interactive 8-Group Stock Matrix';
      case 'donors_list': return 'Donors Directory';
      case 'donors_location': return 'Location & Travel Preferences';
      case 'hospitals_list': return 'Verified Hospitals Directory';
      case 'requester_shield': return 'Requester Abuse & Fraud Shield';
      case 'community_partners': return 'Community Partners & NGOs';
      case 'approvals_queue': return 'Four-Eyes Approvals Queue';
      case 'data_exports': return 'Privacy-Safe Data Exports';
      case 'dpdp_registry': return 'DPDP Privacy & Erasures';
      case 'settings_killswitch': return 'Master Platform Killswitch';
      case 'settings_algorithm': return 'Search Ring Parameters';
      case 'settings_safety': return 'Clinical Safety Desk';
      case 'settings_audit': default: return 'Immutable Cryptographic Audit Logs';
    }
  }
}
