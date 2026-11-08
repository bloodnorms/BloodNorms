// ============================================================================
// BloodNorms | donation_confirmation_dialogs.dart
// Verification dialogs for blood donation: success confirmation & reason sheets
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showDonationVerifiedSuccessDialog({
  required BuildContext context,
  required String name,
  required String group,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BrandColors.statusSuccessTint,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: BrandColors.statusSuccess,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Donation Verified!',
            style: BrandTypography.title3(color: BrandColors.textPrimary),
          ),
        ],
      ),
      content: Text(
        'Successfully confirmed donation for $name ($group). Blood stock and donor history updated.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        AppPillButton(
          label: 'Done',
          height: 40,
          variant: AppPillButtonVariant.primary,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

void showReasonForNotDonatingSheet({
  required BuildContext context,
  required ValueChanged<String> onRecorded,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: BrandColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(BrandColors.radiusDialog)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason for Not Donating',
            style: BrandTypography.title2(color: BrandColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'The request search will reopen for other donors.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 18),
          AppPillButton(
            label: 'Medical Deferral (Doctor decision)',
            variant: AppPillButtonVariant.secondary,
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              onRecorded('Recorded: Medical deferral');
            },
          ),
          const SizedBox(height: 10),
          AppPillButton(
            label: 'Did Not Come / Cancelled',
            variant: AppPillButtonVariant.secondary,
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              onRecorded('Recorded: Donor cancelled');
            },
          ),
          const SizedBox(height: 10),
          AppPillButton(
            label: 'Cancel',
            variant: AppPillButtonVariant.text,
            isFullWidth: true,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
