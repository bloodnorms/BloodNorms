// ============================================================================
// BloodNorms | blood_group_help_sheet.dart
// Clean, minimal modal sheet shown when blood group is unknown
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showBloodGroupHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(BrandColors.radiusDialog)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: BrandColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  "Don't know the group?",
                  style: BrandTypography.title2(color: BrandColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Please check the hospital requisition slip or ask the attending doctor. You can still search blood banks right now, but finding live verified donors requires an exact blood group.',
              style: BrandTypography.body(color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppPillButton(
                label: 'Search Blood Banks Now',
                variant: AppPillButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/b');
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppPillButton(
                label: 'Back',
                variant: AppPillButtonVariant.secondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
