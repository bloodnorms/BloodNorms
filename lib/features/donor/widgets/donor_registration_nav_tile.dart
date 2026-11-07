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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/donor/onboarding'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BrandColors.redTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BrandColors.redShadow,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: BrandColors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Registration Details',
                        style: BrandTypography.headline(
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
