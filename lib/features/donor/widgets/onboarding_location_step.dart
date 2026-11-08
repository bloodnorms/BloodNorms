// ============================================================================
// BloodNorms | onboarding_location_step.dart
// City selection, locality input, and travel limit radius selector
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/speech_bubble.dart';

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
                  color: isSel ? BrandColors.primaryDark : BrandColors.textSecondary,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSel,
              selectedColor: BrandColors.surfaceSoft,
              backgroundColor: BrandColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                side: BorderSide(
                  color: isSel ? BrandColors.primaryDark : BrandColors.borderSubtle,
                  width: 1.0,
                ),
              ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: BrandColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              borderSide: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              borderSide: const BorderSide(color: BrandColors.primaryDark, width: 1.5),
            ),
          ),
          style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: BrandColors.surfaceSoft,
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            border: Border.all(color: BrandColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location_rounded, size: 14, color: BrandColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                'Live Radar GPS: Auto-mapped to $selectedCity coordinates',
                style: BrandTypography.caption(color: BrandColors.textSecondary),
              ),
            ],
          ),
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
            return InkWell(
              onTap: () => onTravelLimitChanged(km),
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? BrandColors.primaryDark : BrandColors.surface,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(
                    color: isSel ? BrandColors.primaryDark : BrandColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: isSel ? BrandColors.shadowSubtle : null,
                ),
                child: Text(
                  '$km KM',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: isSel ? Colors.white : BrandColors.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
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
