// ============================================================================
// BloodNorms | donor_profile_header.dart
// Donor profile header card, gamification hero stats row, and quick setting tiles
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'donor_profile_action_tiles.dart';

class DonorProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String bloodGroup;
  final double weightKg;
  final int donationsCount;
  final String city;
  final String area;
  final double travelRadiusKm;
  final bool isAway;
  final VoidCallback onOpenLocationSettings;

  const DonorProfileHeader({
    super.key,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.weightKg,
    required this.donationsCount,
    required this.city,
    required this.area,
    required this.travelRadiusKm,
    required this.isAway,
    required this.onOpenLocationSettings,
  });

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: BrandColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: BrandColors.statusErrorTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.statusError,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: BrandTypography.title2(color: BrandColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(phone, style: BrandTypography.subhead(color: BrandColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: BrandColors.statusError,
                            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          ),
                          child: Text(
                            bloodGroup,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${weightKg.toStringAsFixed(0)} kg', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hero Gamification Stats Row
        Row(
          children: [
            Expanded(child: _buildStatCard(icon: '🔥', value: '$donationsCount', label: 'DONATIONS')),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(icon: '💎', value: '85', label: 'TRUST')),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(icon: '❤️', value: '${donationsCount * 3}', label: 'LIVES')),
          ],
        ),
        const SizedBox(height: 20),
        DonorProfileActionTiles(
          city: city,
          area: area,
          travelRadiusKm: travelRadiusKm,
          isAway: isAway,
          onOpenLocationSettings: onOpenLocationSettings,
        ),
      ],
    );
  }
}
