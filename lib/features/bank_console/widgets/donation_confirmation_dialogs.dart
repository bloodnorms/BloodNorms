// ============================================================================
// BloodNorms | donation_confirmation_dialogs.dart
// Verification dialogs for blood donation: success confirmation & reason sheets
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showDonationVerifiedSuccessDialog({
  required BuildContext context,
  required String name,
  required String group,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BrandColors.border, width: 2.0),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrandColors.greenTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BrandColors.greenShadow, width: 1.5),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: BrandColors.green,
              size: 24,
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
        ActionButton(
          label: 'DONE',
          height: 44,
          variant: ActionButtonVariant.success,
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason for Not Donating',
            style: BrandTypography.title2(color: BrandColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'The request search will reopen for other donors.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Medical Deferral (Doctor decision)',
            variant: ActionButtonVariant.secondary,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              onRecorded('Recorded: Medical deferral');
            },
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'Did Not Come / Cancelled',
            variant: ActionButtonVariant.secondary,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              onRecorded('Recorded: Donor did not arrive');
            },
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'CANCEL',
            variant: ActionButtonVariant.plain,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
