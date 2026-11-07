// ============================================================================
// BloodNorms | live_tracking_contact_dialogs.dart
// Privacy notice and fallback contact dialogs for donor tracking
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showDonorPrivacyNotice(BuildContext context, String name) {
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
          const Icon(
            Icons.privacy_tip_rounded,
            color: BrandColors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Contact Details',
            style: BrandTypography.title3(color: BrandColors.textPrimary),
          ),
        ],
      ),
      content: Text(
        '$name has been sent an emergency alert. Their direct phone number will be displayed as soon as they confirm availability.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        ActionButton(
          label: 'OK',
          variant: ActionButtonVariant.primary,
          height: 44,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

void showLiveTrackingPhoneFallback(
  BuildContext context,
  String name,
  String phone,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BrandColors.border, width: 2.0),
      ),
      title: Text(
        'Call $name',
        style: BrandTypography.title3(color: BrandColors.textPrimary),
      ),
      content: Text(
        'Phone: $phone\n(Direct donor connection per emergency protocol)',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        ActionButton(
          label: 'CLOSE',
          variant: ActionButtonVariant.primary,
          height: 44,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
