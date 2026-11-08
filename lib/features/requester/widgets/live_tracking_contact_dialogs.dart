// ============================================================================
// BloodNorms | live_tracking_contact_dialogs.dart
// Privacy notice and fallback contact dialogs for donor tracking
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showDonorPrivacyNotice(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.privacy_tip_rounded,
            color: BrandColors.primaryDark,
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
        AppPillButton(
          text: 'OK',
          variant: AppPillButtonVariant.primary,
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
      backgroundColor: BrandColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
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
        AppPillButton(
          text: 'Close',
          variant: AppPillButtonVariant.primary,
          height: 44,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
