// ============================================================================
// BloodNorms | out_of_station_switch_card.dart
// Toggle card to temporarily pause localized blood camp invitations while away
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class OutOfStationSwitchCard extends StatelessWidget {
  final bool isAway;
  final ValueChanged<bool> onChanged;

  const OutOfStationSwitchCard({
    super.key,
    required this.isAway,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currently Out of Town / Away',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pause localized blood camp invitations while traveling',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 11,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAway,
            activeThumbColor: BrandColors.red,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
