// ============================================================================
// BloodNorms | donor_camps_city_sheet.dart
// Modal sheet allowing donor to choose active viewing city or all regions
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showDonorCampsCitySheet({
  required BuildContext context,
  required String selectedCity,
  required List<String> supportedCities,
  required ValueChanged<String> onCitySelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Viewing City / Region', style: BrandTypography.title2(color: BrandColors.textPrimary)),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'View voluntary blood drives in your area or adjacent districts.',
            style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: supportedCities.map((city) {
              final isSel = selectedCity.toLowerCase() == city.toLowerCase();
              return ChoiceChip(
                label: Text(
                  city == 'All' ? '🌐 All Regions' : city,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : BrandColors.textPrimary,
                  ),
                ),
                selected: isSel,
                selectedColor: BrandColors.red,
                backgroundColor: BrandColors.bgGrouped,
                onSelected: (val) {
                  Navigator.pop(ctx);
                  onCitySelected(city);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

