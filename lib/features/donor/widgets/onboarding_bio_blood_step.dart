// ============================================================================
// BloodNorms | onboarding_bio_blood_step.dart
// Bio & Blood Group selection step components for donor onboarding wizard
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/blood_group_tile.dart';

class OnboardingBioStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController weightController;

  const OnboardingBioStep({
    super.key,
    required this.nameController,
    required this.weightController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '⚖️',
          text: 'Rule BR-01: Donors must be aged 18–65 and weigh at least 45 kg.',
        ),
        const SizedBox(height: 20),
        Text('Basic Details', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 16),
        AppTextField(
          label: 'FULL NAME',
          controller: nameController,
          hintText: 'e.g., Ramesh Varma',
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'WEIGHT (KG)',
          controller: weightController,
          keyboardType: TextInputType.number,
          hintText: 'e.g., 68',
          prefixIcon: Icons.fitness_center_rounded,
        ),
      ],
    );
  }
}

class OnboardingBloodStep extends StatelessWidget {
  final BloodGroup? bloodGroup;
  final bool plateletsWilling;
  final ValueChanged<BloodGroup> onBloodGroupSelected;
  final ValueChanged<bool> onPlateletsChanged;

  const OnboardingBloodStep({
    super.key,
    required this.bloodGroup,
    required this.plateletsWilling,
    required this.onBloodGroupSelected,
    required this.onPlateletsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '🩸',
          text: 'Select your blood group! You can also opt-in for platelet donations.',
        ),
        const SizedBox(height: 20),
        Text('Your Blood Group', style: BrandTypography.title1(color: BrandColors.textPrimary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: BloodGroup.values.map((bg) {
            return BloodGroupTile(
              bloodGroup: bg,
              isSelected: bloodGroup == bg,
              size: 78,
              onTap: () => onBloodGroupSelected(bg),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: BrandColors.border,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Willing for Platelets?', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Apheresis donation at major centres', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                ],
              ),
              Switch(
                value: plateletsWilling,
                activeThumbColor: BrandColors.red,
                onChanged: onPlateletsChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
