// ============================================================================
// BloodNorms | admin_header.dart
// Modern Minimal Top Breadcrumb & Status Bar with Action Pill
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: BrandColors.background,
        border: Border(
          bottom: BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations / ${getPageBreadcrumb(activePage)}',
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: BrandColors.statusSuccessTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: BrandColors.statusSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live sync',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: BrandColors.statusSuccess,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppPillButton(
                label: 'Quick actions',
                icon: Icons.bolt_rounded,
                variant: AppPillButtonVariant.primary,
                onPressed: onQuickActions,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String getPageBreadcrumb(String pageId) {
    if (pageId.startsWith('broadcast')) return 'Broadcast / ${getPageTitle(pageId)}';
    if (pageId.startsWith('voice')) return 'AI Voice / ${getPageTitle(pageId)}';
    if (pageId.startsWith('whatsapp')) return 'WhatsApp / ${getPageTitle(pageId)}';
    if (pageId.startsWith('camps')) return 'Blood Camps / ${getPageTitle(pageId)}';
    if (pageId.startsWith('banks')) return 'Blood Centers / ${getPageTitle(pageId)}';
    if (pageId.startsWith('donors')) return 'Donors / ${getPageTitle(pageId)}';
    if (pageId.startsWith('hospitals') || pageId.startsWith('requester') || pageId.startsWith('community')) {
      return 'Healthcare / ${getPageTitle(pageId)}';
    }
    if (pageId.startsWith('approvals') || pageId.startsWith('data') || pageId.startsWith('dpdp')) {
      return 'Governance / ${getPageTitle(pageId)}';
    }
    if (pageId.startsWith('settings')) return 'Settings / ${getPageTitle(pageId)}';
    return getPageTitle(pageId);
  }

  static String getPageTitle(String pageId) {
    switch (pageId) {
      case 'dashboard': return 'Operations Cockpit';
      case 'crisis_radar': return 'Crisis Radar';
      case 'needs_human': return 'Triage Queue';
      case 'broadcast_dispatch': return 'Regional Broadcast';
      case 'broadcast_audience': return 'Audience Inspector';
      case 'broadcast_history': return 'Delivery History';
      case 'voice_simulator': return 'Voice Simulator';
      case 'voice_prompts': return 'Clinical Prompts';
      case 'voice_safety': return 'Safety Caps';
      case 'whatsapp_bot': return 'Assistant Bot';
      case 'whatsapp_templates': return 'Template Builder';
      case 'whatsapp_telecom': return 'Telecom Rates';
      case 'camps_list': return 'Scheduled Drives';
      case 'camps_create': return 'Schedule New Drive';
      case 'banks_directory': return 'Connected Centers';
      case 'banks_stock': return 'Stock Matrix';
      case 'donors_list': return 'Donors Directory';
      case 'donors_location': return 'Travel Preferences';
      case 'hospitals_list': return 'Hospitals Directory';
      case 'requester_shield': return 'Fraud Shield';
      case 'community_partners': return 'Community Partners';
      case 'approvals_queue': return 'Approvals Queue';
      case 'data_exports': return 'Data Exports';
      case 'dpdp_registry': return 'DPDP Privacy';
      case 'settings_killswitch': return 'Emergency Killswitch';
      case 'settings_algorithm': return 'Search Parameters';
      case 'settings_safety': return 'Clinical Safety';
      case 'settings_audit': default: return 'Audit Logs';
    }
  }
}
