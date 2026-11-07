// ============================================================================
// BloodNorms | donor_pause_sheet.dart
// Modal sheet allowing donor to temporarily pause emergency alerts
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showDonorPauseSheet(
  BuildContext context, {
  required ValueChanged<bool> onToggleAvailability,
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
            'Pause Emergency Alerts',
            style: BrandTypography.title2(color: BrandColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'You will not be contacted for emergency requests during this period.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Pause for 7 days',
            variant: ActionButtonVariant.secondary,
            height: 48,
            onPressed: () {
              onToggleAvailability(false);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'Pause for 30 days',
            variant: ActionButtonVariant.secondary,
            height: 48,
            onPressed: () {
              onToggleAvailability(false);
              Navigator.pop(ctx);
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
