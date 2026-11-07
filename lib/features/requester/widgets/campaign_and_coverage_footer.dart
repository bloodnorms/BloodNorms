// ============================================================================
// BloodNorms | campaign_and_coverage_footer.dart
// Voluntary Blood Donation Campaign Banner & Live Pilot Regional Footer
// ============================================================================

import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFBEB),
                Color(0xFFFEF3C7),
                Color(0xFFFDE68A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCD34D), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🇮🇳', style: TextStyle(fontSize: 22)),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'One Drop of Humanity. Give Blood. Save Lives.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFB45309),
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
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE52E2E),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Color(0xFFE52E2E),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Live Pilot: Rajahmundry & Kakinada (AP)',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
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
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
