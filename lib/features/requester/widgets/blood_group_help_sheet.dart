// ============================================================================
// BloodNorms | blood_group_help_sheet.dart
// Modal sheet shown when the requester does not know the required blood group
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showBloodGroupHelpSheet(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuoColors.redTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: DuoColors.red, width: 1.5),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: DuoColors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Don't know the group?",
                style: DuoTypography.title2(color: DuoColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Please check the hospital requisition slip or ask the attending doctor. You can still search blood banks right now, but finding live verified donors requires an exact blood group.',
            style: DuoTypography.body(color: DuoColors.textSecondary),
          ),
          const SizedBox(height: 20),
          DuoButton(
            label: 'BROWSE BLOOD BANKS NOW',
            variant: DuoButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/b');
            },
          ),
          const SizedBox(height: 10),
          DuoButton(
            label: 'BACK',
            variant: DuoButtonVariant.plain,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
