// ============================================================================
// BloodNorms | onboarding_location_step.dart
// City selection, locality input, and travel limit radius selector
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

class OnboardingLocationStep extends StatelessWidget {
  final String selectedCity;
  final TextEditingController areaController;
  final int travelLimitKm;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<int> onTravelLimitChanged;

  const OnboardingLocationStep({
    super.key,
    required this.selectedCity,
    required this.areaController,
    required this.travelLimitKm,
    required this.onCityChanged,
    required this.onTravelLimitChanged,
  });

  static const List<int> travelOptions = [3, 5, 10, 25, 50, 100];
  static const List<String> cities = ['Rajahmundry', 'Kakinada', 'Visakhapatnam', 'Vijayawada', 'Guntur', 'Eluru'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpeechBubble(
          emoji: '🚗',
          text: 'Where are you based, and how far can you travel for emergency blood drives?',
        ),
        const SizedBox(height: 18),
        Text('Primary City', style: BrandTypography.title2(color: BrandColors.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((c) {
            final isSel = selectedCity.toLowerCase() == c.toLowerCase();
            return ChoiceChip(
              label: Text(
                c,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: isSel ? Colors.white : BrandColors.textPrimary,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSel,
              selectedColor: BrandColors.red,
              backgroundColor: BrandColors.bgGrouped,
              onSelected: (_) => onCityChanged(c),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('Area / Locality', style: BrandTypography.title2(color: BrandColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: areaController,
          decoration: InputDecoration(
            hintText: 'e.g. Danavaipeta, Kotipalli, Morampudi',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            fillColor: Colors.white,
            filled: true,
          ),
          style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
        ),
        const SizedBox(height: 18),
        Text('Maximum Travel Limit', style: BrandTypography.title2(color: BrandColors.textPrimary)),
        const SizedBox(height: 4),
        const Text(
          'Drives outside this radius will not disturb you.',
          style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: travelOptions.map((km) {
            final isSel = travelLimitKm == km;
            return GestureDetector(
              onTap: () => onTravelLimitChanged(km),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSel ? BrandColors.red : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? BrandColors.redShadow : BrandColors.border,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSel ? BrandColors.redShadow : BrandColors.border,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  '$km KM',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: isSel ? Colors.white : BrandColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

