// ============================================================================
// BloodNorms | campaign_and_coverage_footer.dart
// Voluntary Blood Donation Campaign Banner & Live Pilot Regional Footer
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class CampaignAndCoverageFooter extends StatelessWidget {
  const CampaignAndCoverageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. National Blood Donation Campaign Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrandColors.statusWarningTint,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.statusWarning.withValues(alpha: 0.25), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: BrandColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🇮🇳', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'National Voluntary Blood Donation',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'One Drop of Humanity. Give Blood. Save Lives.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11.5,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Carousel indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 4,
              decoration: BoxDecoration(
                color: BrandColors.primaryAction,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: BrandColors.borderStrong,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: BrandColors.borderStrong,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Live Pilot Status & Coverage Footer
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.background,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(
                    color: BrandColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: BrandColors.statusError,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Live Pilot: Rajahmundry & Kakinada (AP)',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'BloodNorms is non-commercial. We never ask for OTP or money.',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 11,
                  color: BrandColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
