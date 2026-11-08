// ============================================================================
// BloodNorms | donor_profile_action_tiles.dart
// Interactive profile settings navigation tiles for registration & alert preferences
// ============================================================================

import 'package:flutter/material.dart';
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
        const DonorRegistrationNavTile(),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
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
                            ? BrandColors.statusWarningTint
                            : BrandColors.statusSuccessTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        border: Border.all(
                          color: isAway
                              ? BrandColors.statusWarning.withValues(alpha: 0.3)
                              : BrandColors.statusSuccess.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        isAway
                            ? Icons.flight_takeoff_rounded
                            : Icons.location_on_outlined,
                        color: isAway
                            ? BrandColors.statusWarning
                            : BrandColors.statusSuccess,
                        size: 22,
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
                                style: BrandTypography.title3(
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
                                    color: BrandColors.statusWarningTint,
                                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                                  ),
                                  child: const Text(
                                    'AWAY',
                                    style: TextStyle(
                                      fontFamily: BrandTypography.fontFamily,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.statusWarning,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAway
                                ? 'Alerts muted · Tap to reactivate'
                                : '$area, $city · ${travelRadiusKm.toInt()} km radius',
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
                      color: BrandColors.textMuted,
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
