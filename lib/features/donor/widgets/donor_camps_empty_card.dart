// ============================================================================
// BloodNorms | donor_camps_empty_card.dart
// Empty state card when no donation drives match the selected region and radius
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class DonorCampsEmptyCard extends StatelessWidget {
  final String selectedCity;
  final double selectedRadiusKm;
  final VoidCallback onViewAll;

  const DonorCampsEmptyCard({
    super.key,
    required this.selectedCity,
    required this.selectedRadiusKm,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        boxShadow: BrandColors.shadowSubtle,
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_off_rounded, size: 40, color: BrandColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'No voluntary blood drives found in $selectedCity within ${selectedRadiusKm.toInt()} km.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppPillButton(
            onPressed: onViewAll,
            icon: Icons.public_rounded,
            text: 'View All Regional Drives',
            variant: AppPillButtonVariant.secondary,
            height: 44,
          ),
        ],
      ),
    );
  }
}
