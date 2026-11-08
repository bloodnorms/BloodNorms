// ============================================================================
// BloodNorms | donor_dpdp_dialogs.dart
// DPDP Act 2023 compliance dialogs (Data Export and Right to Erasure / Deletion)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showDonorExportDialog(BuildContext context, String donorName) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrandColors.surfaceSoft,
              borderRadius: BorderRadius.circular(BrandColors.radiusSmall),
            ),
            child: const Icon(Icons.description_rounded, color: BrandColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Text('Export Complete', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        ],
      ),
      content: Text(
        'Your personal donor data for $donorName has been securely prepared in compliance with DPDP Act rights.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        AppPillButton(
          text: 'Done',
          height: 44,
          variant: AppPillButtonVariant.primary,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

void showDonorConfirmDeleteDialog(BuildContext context, String? donorId) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrandColors.redTint,
              borderRadius: BorderRadius.circular(BrandColors.radiusSmall),
            ),
            child: const Icon(Icons.delete_forever_rounded, color: BrandColors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Text('Delete Account?', style: BrandTypography.title3(color: BrandColors.red)),
        ],
      ),
      content: Text(
        'This will permanently delete your donor account from Supabase, remove your contact number, and stop all emergency alerts.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppPillButton(
                text: 'Cancel',
                height: 44,
                variant: AppPillButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPillButton(
                text: 'Delete',
                height: 44,
                variant: AppPillButtonVariant.destructive,
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (donorId != null) {
                    await SupabaseService().deleteDonor(donorId);
                  }
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('current_donor_id');
                  await prefs.remove('current_donor_name');
                  await prefs.remove('current_donor_phone');
                  await prefs.remove('current_donor_blood_group');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Donor account permanently deleted from Supabase.'),
                        backgroundColor: BrandColors.red,
                      ),
                    );
                    context.go('/');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
