// ============================================================================
// BloodNorms | onboarding_health_step.dart
// Rapid health screening step (10 neutral questions per BR-15)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

class OnboardingHealthStep extends StatelessWidget {
  final int healthIndex;
  final List<String> questions;
  final VoidCallback onAnswer;

  const OnboardingHealthStep({
    super.key,
    required this.healthIndex,
    this.questions = standardHealthQuestions,
    required this.onAnswer,
  });

  static const List<String> standardHealthQuestions = [
    'Do you have fever, cough or cold today?',
    'Any illness in the last 4 weeks (jaundice, malaria, dengue)?',
    'Are you currently taking any antibiotics?',
    'Have you received any vaccine in the past 4 weeks?',
    'Any surgery or dental extraction in the past 6 months?',
    'Any tattoo, piercing, or acupuncture in the past 6 months?',
    'Are you pregnant or currently breastfeeding?',
    'Have you consumed alcohol in the past 24 hours?',
    'Any chronic heart, kidney, epilepsy or bleeding disorder?',
    'Have you travelled to a high-risk malaria zone recently?',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health Quick-Check', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 6),
        Text(
          'Question ${healthIndex + 1} of 10 (BR-15)',
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BrandColors.red,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: BrandColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                questions[healthIndex],
                style: BrandTypography.title2(color: BrandColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      label: 'NO',
                      variant: ActionButtonVariant.secondary,
                      onPressed: onAnswer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ActionButton(
                      label: 'YES',
                      variant: ActionButtonVariant.primary,
                      onPressed: onAnswer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
