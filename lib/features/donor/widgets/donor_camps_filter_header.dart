// ============================================================================
// BloodNorms | donor_camps_filter_header.dart
// Region filter, radius stepper, and travel status banner for donation camps
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/speech_bubble.dart';

class DonorCampsFilterHeader extends StatelessWidget {
  final bool isAway;
  final String selectedCity;
  final double selectedRadiusKm;
  final VoidCallback onOpenCityPicker;
  final ValueChanged<double> onRadiusChanged;

  const DonorCampsFilterHeader({
    super.key,
    required this.isAway,
    required this.selectedCity,
    required this.selectedRadiusKm,
    required this.onOpenCityPicker,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAway)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.flight_takeoff_rounded, color: Color(0xFFB45309), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You are marked as "Away / Out of Town". Localized broadcasts are temporarily paused.',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SpeechBubble(
          emoji: '⛺',
          text: 'Join voluntary blood drives in ${selectedCity == "All" ? "Andhra Pradesh" : selectedCity}! Meet fellow donors and save lives together.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: BrandColors.surface,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
            boxShadow: BrandColors.shadowSubtle,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: BrandColors.primaryDark, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT REGION',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                      Text(
                        selectedCity == 'All' ? 'All Districts' : selectedCity,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: onOpenCityPicker,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 16, color: BrandColors.textPrimary),
                      SizedBox(width: 4),
                      Text(
                        'Change City',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'Search Radius: ',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: BrandColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [5.0, 15.0, 25.0, 50.0, 100.0].map((r) {
                    final isSel = selectedRadiusKm == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          '${r.toInt()} km',
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? BrandColors.primaryDark : BrandColors.textSecondary,
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
                        onSelected: (_) => onRadiusChanged(r),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
