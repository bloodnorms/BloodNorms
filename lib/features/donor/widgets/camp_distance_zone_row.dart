// ============================================================================
// BloodNorms | camp_distance_zone_row.dart
// Distance indicator, travel zone badge, and directions action button for camp card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class CampDistanceZoneRow extends StatelessWidget {
  final double distanceKm;
  final bool inTravelZone;
  final VoidCallback onOpenDirections;

  const CampDistanceZoneRow({
    super.key,
    required this.distanceKm,
    required this.inTravelZone,
    required this.onOpenDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: BrandColors.bgGrouped,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: BrandColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.near_me_rounded,
                size: 12,
                color: BrandColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '~${distanceKm.toStringAsFixed(1)} KM Away',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: inTravelZone ? BrandColors.greenTint : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            inTravelZone ? '✓ In Your Zone' : 'Outside Zone',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: inTravelZone ? BrandColors.green : const Color(0xFFB45309),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onOpenDirections,
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.directions_rounded,
                  size: 14,
                  color: BrandColors.red,
                ),
                SizedBox(width: 3),
                Text(
                  'Route',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
