// ============================================================================
// BloodNorms | admin_four_eyes_dialog.dart
// Modern Minimal Four-Eyes Governance Approval Dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showFourEyesApprovalDialog({
  required BuildContext context,
  required int recipientCount,
  required VoidCallback onNavigateToApprovals,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: const Row(
        children: [
          Icon(Icons.rule_folder_outlined, color: BrandColors.accent, size: 22),
          SizedBox(width: 10),
          Text(
            'Four-Eyes approval required',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        'Broadcasting to $recipientCount recipients exceeds the single-admin threshold (>200 donors).\n\nThis request has been automatically routed to the Four-Eyes Approvals Desk for second-admin verification.',
        style: const TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 13,
          color: BrandColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        AppPillButton(
          label: 'Go to approvals queue',
          variant: AppPillButtonVariant.primary,
          onPressed: () {
            Navigator.pop(ctx);
            onNavigateToApprovals();
          },
        ),
        const SizedBox(width: 8),
        AppPillButton(
          label: 'Close',
          variant: AppPillButtonVariant.secondary,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
