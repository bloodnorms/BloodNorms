// ============================================================================
// BloodNorms | quick_actions_sheet.dart
// Modern Minimal Quick Actions Bottom Sheet Modal
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
    backgroundColor: BrandColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(BrandColors.radiusDialog)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: BrandColors.borderStrong,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.bolt_rounded, color: BrandColors.accent, size: 24),
              title: Text(
                'Quick actions',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: BrandColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Fast operational shortcuts for emergency situations',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
            ),
            const Divider(color: BrandColors.borderSubtle),
            _buildActionTile(
              icon: Icons.campaign_outlined,
              iconColor: BrandColors.accent,
              title: 'Dispatch regional broadcast',
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('broadcast_dispatch');
              },
            ),
            _buildActionTile(
              icon: Icons.event_available_outlined,
              iconColor: BrandColors.statusSuccess,
              title: 'Schedule new blood donation drive',
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('camps_create');
              },
            ),
            _buildActionTile(
              icon: Icons.verified_user_outlined,
              iconColor: BrandColors.accent,
              title: 'Open four-eyes approvals queue',
              onTap: () {
                Navigator.pop(ctx);
                onNavigate('approvals_queue');
              },
            ),
            _buildActionTile(
              icon: Icons.power_settings_new_rounded,
              iconColor: BrandColors.statusError,
              title: 'Toggle platform emergency killswitch',
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

Widget _buildActionTile({
  required IconData icon,
  required Color iconColor,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 18),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: BrandTypography.fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: BrandColors.textPrimary,
      ),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: BrandColors.textMuted),
    onTap: onTap,
  );
}
