// ============================================================================
// BloodNorms | donor_profile_action_tiles.dart
// Interactive profile settings navigation tiles for registration & alert preferences
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'donor_registration_nav_tile.dart';

class DonorProfileActionTiles extends StatelessWidget {
  final String city;
  final String area;
  final double travelRadiusKm;
  final bool isAway;
  final VoidCallback onOpenLocationSettings;

  const DonorProfileActionTiles({
    super.key,
    required this.city,
    required this.area,
    required this.travelRadiusKm,
    required this.isAway,
    required this.onOpenLocationSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Onboarding Wizard Tile
        // Onboarding Wizard Tile
        const DonorRegistrationNavTile(),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: BrandColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onOpenLocationSettings,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isAway
                            ? const Color(0xFFFEF3C7)
                            : BrandColors.greenTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAway
                              ? const Color(0xFFFCD34D)
                              : BrandColors.greenShadow,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isAway
                            ? Icons.flight_takeoff_rounded
                            : Icons.location_on_rounded,
                        color: isAway
                            ? const Color(0xFFB45309)
                            : BrandColors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Location & Alert Preferences',
                                style: BrandTypography.headline(
                                  color: BrandColors.textPrimary,
                                ),
                              ),
                              if (isAway) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AWAY',
                                    style: TextStyle(
                                      fontFamily: BrandTypography.fontFamily,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$city ($area) · ${travelRadiusKm.toInt()} km travel limit',
                            style: BrandTypography.caption(
                              color: BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: BrandColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
