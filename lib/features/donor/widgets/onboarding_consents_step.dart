// ============================================================================
// BloodNorms | onboarding_consents_step.dart
// Donor consent confirmation step (BR-12, DPDP, medical fitness acknowledgment)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

class OnboardingConsentsStep extends StatelessWidget {
  final List<bool> consents;
  final void Function(int index, bool value) onConsentChanged;

  const OnboardingConsentsStep({
    super.key,
    required this.consents,
    required this.onConsentChanged,
  });

  static const List<String> consentLabels = [
    'I agree to be contacted by WhatsApp & automated calls for emergency blood needs.',
    'My phone number will only be shared with the family after I accept a request.',
    'BloodNorms never asks for money or OTP. Blood is always voluntary and free.',
    'The attending doctor at the blood bank does the final medical fitness check.',
    'I am at least 18 years old and weigh 45 kg or more.',
    'I can pause or delete my donor account at any time with complete data removal.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '📜',
          text: 'Please review and confirm these simple donor rules to protect everyone!',
        ),
        const SizedBox(height: 20),
        Text('Your Consents', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 16),
        ...List.generate(consentLabels.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BrandColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: BrandColors.border,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Switch(
                  value: consents[i],
                  activeThumbColor: BrandColors.red,
                  onChanged: (val) => onConsentChanged(i, val),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    consentLabels[i],
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

