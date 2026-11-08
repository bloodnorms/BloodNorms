// ============================================================================
// BloodNorms | live_tracking_fulfillment_dialogs.dart
// Outcome dialogs (Got Blood, Stop Search, Donation Confirmation, Privacy Fallback)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

export 'live_tracking_contact_dialogs.dart';

void showGotBloodSheet({
  required BuildContext context,
  required ValueChanged<String> onSelectedReason,
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
          Text('Blood Obtained', style: BrandTypography.title2(color: BrandColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Where was the blood obtained? Your response helps keep blood bank stock accurate.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 18),
          AppPillButton(
            label: 'Found stock at blood bank (+3 trust)',
            variant: AppPillButtonVariant.primary,
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Found stock at bank');
            },
          ),
          const SizedBox(height: 10),
          AppPillButton(
            label: 'Connected with donor via BloodNorms',
            variant: AppPillButtonVariant.tonal,
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Found verified donor');
            },
          ),
          const SizedBox(height: 10),
          AppPillButton(
            label: 'Bank stock was incorrect (-8 trust)',
            variant: AppPillButtonVariant.secondary,
            isFullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              onSelectedReason('Bank stock was missing');
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

void showStopSearchDialog({
  required BuildContext context,
  required VoidCallback onConfirmStop,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: Text('Stop Search?', style: BrandTypography.title2(color: BrandColors.statusError)),
      content: Text(
        'This will cancel the active request and notify contacted donors that blood is no longer needed.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppPillButton(
                label: 'Keep Searching',
                variant: AppPillButtonVariant.secondary,
                height: 40,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPillButton(
                label: 'Stop Search',
                variant: AppPillButtonVariant.destructive,
                height: 40,
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
            child: const Icon(Icons.check_circle_outline_rounded, color: BrandColors.statusSuccess, size: 22),
          ),
          const SizedBox(width: 10),
          Text('Donation Confirmed', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        ],
      ),
      content: Text(
        'Donation pass $code verified and recorded in Supabase.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        AppPillButton(
          label: 'Done',
          variant: AppPillButtonVariant.primary,
          height: 40,
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
      backgroundColor: BrandColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: Text('Request Completed', style: BrandTypography.title2(color: BrandColors.textPrimary)),
      content: Text(
        'Outcome recorded: $reason. Contacted donors have been notified.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        AppPillButton(
          label: 'Done',
          variant: AppPillButtonVariant.primary,
          height: 40,
          onPressed: () {
            Navigator.pop(ctx);
            context.go('/');
          },
        ),
      ],
    ),
  );
}
