// ============================================================================
// BloodNorms | quick_actions_sheet.dart
// Superhero Command Actions Bottom Sheet Modal
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showQuickActionsSheet({
  required BuildContext context,
  required ValueChanged<String> onNavigate,
  required VoidCallback onToggleKillswitch,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.bolt_rounded, color: BrandColors.red, size: 28),
              title: Text('Superhero Command Actions', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('Instant executive overrides for live emergency crisis situations'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.campaign_rounded, color: BrandColors.red),
              title: const Text('Dispatch Regional Camp Broadcast'),
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('broadcast_dispatch');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available_rounded, color: Color(0xFF2563EB)),
              title: const Text('Schedule New Blood Donation Camp'),
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('camps_create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flaky_rounded, color: Color(0xFFD97706)),
              title: const Text('Open Four-Eyes Approvals Desk'),
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('approvals_queue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new_rounded, color: BrandColors.red),
              title: const Text('Toggle Platform Emergency Kill Switch'),
              onTap: () {
                Navigator.pop(ctx);
                onToggleKillswitch();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
