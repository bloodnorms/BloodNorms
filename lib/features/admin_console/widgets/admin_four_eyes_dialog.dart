// ============================================================================
// BloodNorms | admin_four_eyes_dialog.dart
// Dialog shown when a broadcast request exceeds single-admin threshold (>200)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showFourEyesApprovalDialog({
  required BuildContext context,
  required int recipientCount,
  required VoidCallback onNavigateToApprovals,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.rule_folder_outlined, color: BrandColors.red),
          SizedBox(width: 8),
          Text(
            'Four-Eyes Approval Required',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      content: Text(
        'Broadcasting to $recipientCount recipients exceeds single-admin threshold (>200 donors).\n\nRouted to Four-Eyes Approvals Desk for second-admin verification.',
        style: const TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 13,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onNavigateToApprovals();
          },
          child: const Text(
            'Go to Approvals Queue',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              color: BrandColors.red,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: BrandColors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Acknowledged'),
        ),
      ],
    ),
  );
}
