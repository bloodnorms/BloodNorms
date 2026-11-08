// ============================================================================
// BloodNorms | donors_location_distribution_card.dart
// Donor regional distribution and travel preferences card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorsLocationDistributionCard extends StatelessWidget {
  const DonorsLocationDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donor regional distribution & travel preferences',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationItem('Rajahmundry (Primary Pilot)', '340 donors · Average travel radius: 12.4 km'),
          _buildLocationItem('Kakinada (Extended Zone)', '85 donors'),
          _buildLocationItem('Visakhapatnam', '15 donors'),
          _buildLocationItem('Vijayawada', '10 donors'),
          _buildLocationItem('Currently out of station / away', '12 donors (Auto-suppressed from broadcasts)', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String title, String subtitle, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: BrandColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
          if (isWarning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: BrandColors.statusWarningTint,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
              child: const Text(
                'Auto-suppressed',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.statusWarning,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

