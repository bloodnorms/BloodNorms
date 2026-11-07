// ============================================================================
// BloodNorms | onboarding_contact_steps.dart
// Phone and Email input step widgets for donor onboarding wizard
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class OnboardingPhoneStep extends StatelessWidget {
  final TextEditingController controller;

  const OnboardingPhoneStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '📱',
          text: 'Welcome! First, enter your mobile number. We verify via WhatsApp OTP—zero spam ever!',
        ),
        const SizedBox(height: 24),
        Text('Mobile Number', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          hintText: 'e.g., 9848012345',
          prefixIcon: Icons.phone_rounded,
        ),
      ],
    );
  }
}

class OnboardingEmailStep extends StatelessWidget {
  final TextEditingController controller;

  const OnboardingEmailStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '📧',
          text: 'Great! What is your email address? Used for annual eligibility checkups.',
        ),
        const SizedBox(height: 24),
        Text('Email Address', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_rounded,
        ),
      ],
    );
  }
}
