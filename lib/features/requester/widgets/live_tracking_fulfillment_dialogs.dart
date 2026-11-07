// ============================================================================
// BloodNorms | live_tracking_fulfillment_dialogs.dart
// Outcome dialogs (Got Blood, Stop Search, Donation Confirmation, Privacy Fallback)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showGotBloodSheet({
  required BuildContext context,
  required ValueChanged<String> onSelectedReason,
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
          Text('Got Blood! Close Request?', style: BrandTypography.title2(color: BrandColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Where was the blood obtained? Feedback helps maintain blood bank accuracy.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Yes, stock was there (+3 trust)',
            variant: ActionButtonVariant.success,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Found stock at bank');
            },
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'Found donor through BloodNorms',
            variant: ActionButtonVariant.primary,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Found verified donor');
            },
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'No, bank stock was wrong (-8 trust)',
            variant: ActionButtonVariant.secondary,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Bank stock was missing');
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

void showStopSearchDialog({
  required BuildContext context,
  required VoidCallback onConfirmStop,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BrandColors.border, width: 2.0),
      ),
      title: Text('Stop Search?', style: BrandTypography.title2(color: BrandColors.red)),
      content: Text(
        'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'KEEP SEARCHING',
                variant: ActionButtonVariant.secondary,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionButton(
                label: 'STOP',
                variant: ActionButtonVariant.destructive,
                height: 44,
                onPressed: () {
                  Navigator.pop(ctx);
                  onConfirmStop();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void showDonationConfirmedDialog(BuildContext context, String code) {
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BrandColors.greenShadow, width: 1.5),
            ),
            child: const Icon(Icons.check_circle_rounded, color: BrandColors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Text('Donation Confirmed!', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        ],
      ),
      content: Text(
        'Donation pass $code verified and recorded in Supabase.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        ActionButton(
          label: 'DONE',
          variant: ActionButtonVariant.success,
          height: 44,
          onPressed: () {
            Navigator.pop(ctx);
            context.go('/');
          },
        ),
      ],
    ),
  );
}

void showRequestCompletedDialog(BuildContext context, String reason) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BrandColors.border, width: 2.0),
      ),
      title: Text('Request Completed', style: BrandTypography.title2(color: BrandColors.textPrimary)),
      content: Text(
        'Outcome recorded: $reason. Contacted donors have been notified.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        ActionButton(
          label: 'DONE',
          variant: ActionButtonVariant.primary,
          height: 44,
          onPressed: () {
            Navigator.pop(ctx);
            context.go('/');
          },
        ),
      ],
    ),
  );
}

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
          const Icon(Icons.privacy_tip_rounded, color: BrandColors.red, size: 24),
          const SizedBox(width: 8),
          Text('Contact Details', style: BrandTypography.title3(color: BrandColors.textPrimary)),
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

void showLiveTrackingPhoneFallback(BuildContext context, String name, String phone) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BrandColors.border, width: 2.0),
      ),
      title: Text('Call $name', style: BrandTypography.title3(color: BrandColors.textPrimary)),
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
