// ============================================================================
// BloodNorms | donor_registration_nav_tile.dart
// Interactive navigation tile to update donor registration & health details
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorRegistrationNavTile extends StatelessWidget {
  const DonorRegistrationNavTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        boxShadow: BrandColors.shadowSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          onTap: () => context.push('/donor/onboarding'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(BrandColors.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: BrandColors.primaryDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Registration Details',
                        style: BrandTypography.title3(
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Update health info and travel radius',
                        style: BrandTypography.caption(
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: BrandColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
