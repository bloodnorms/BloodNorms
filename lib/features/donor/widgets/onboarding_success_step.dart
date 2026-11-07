// ============================================================================
// BloodNorms | onboarding_success_step.dart
// Celebration screen displayed upon successful donor profile registration
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class OnboardingSuccessStep extends StatelessWidget {
  const OnboardingSuccessStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: BrandColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BrandColors.greenShadow,
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'YOU ARE ACTIVE! 🎉',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BrandColors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your donor profile is verified. You will only be alerted for genuine emergency needs in Rajahmundry matching your group.',
            style: BrandTypography.body(color: BrandColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

