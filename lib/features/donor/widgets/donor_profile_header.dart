// ============================================================================
// BloodNorms | donor_profile_header.dart
// Donor profile header card, gamification hero stats row, and quick setting tiles
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
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
              fontWeight: FontWeight.bold,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: BrandColors.redTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: BrandColors.redShadow, width: 2.0),
                  boxShadow: const [
                    BoxShadow(color: BrandColors.border, offset: Offset(0, 3), blurRadius: 0),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.red,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 4),
                    Text(phone, style: BrandTypography.subhead(color: BrandColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: BrandColors.red,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: BrandColors.redShadow, offset: Offset(0, 2), blurRadius: 0),
                            ],
                          ),
                          child: Text(
                            bloodGroup,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
        const SizedBox(height: 20),

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
        const SizedBox(height: 24),

        // Onboarding Wizard Tile
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [BoxShadow(color: BrandColors.border, offset: Offset(0, 4), blurRadius: 0)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push('/donor/onboarding'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: BrandColors.redTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BrandColors.redShadow, width: 1.5),
                      ),
                      child: const Icon(Icons.badge_rounded, color: BrandColors.red, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Update Registration Details', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Update health info and travel radius', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: BrandColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Location & Alert Settings Tile
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [BoxShadow(color: BrandColors.border, offset: Offset(0, 4), blurRadius: 0)],
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
                        color: isAway ? const Color(0xFFFEF3C7) : BrandColors.greenTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAway ? const Color(0xFFFCD34D) : BrandColors.greenShadow,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isAway ? Icons.flight_takeoff_rounded : Icons.location_on_rounded,
                        color: isAway ? const Color(0xFFB45309) : BrandColors.green,
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
                              Text('Location & Alert Preferences', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                              if (isAway) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('AWAY', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('$city ($area) · ${travelRadiusKm.toInt()} km travel limit', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: BrandColors.textSecondary),
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

