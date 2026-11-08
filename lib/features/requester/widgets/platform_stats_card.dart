// ============================================================================
// BloodNorms | platform_stats_card.dart
// Live Platform Stats Counter: Real Dynamic Metrics from Supabase
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class PlatformStatsCard extends StatelessWidget {
  final int registeredDonors;
  final int bloodCenters;
  final int campsOrganised;
  final bool isLoading;

  const PlatformStatsCard({
    super.key,
    required this.registeredDonors,
    required this.bloodCenters,
    required this.campsOrganised,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            count: isLoading ? '...' : '$registeredDonors',
            label: 'Registered Donors',
          ),
          Container(
            width: 1,
            height: 32,
            color: BrandColors.borderSubtle,
          ),
          _buildStatColumn(
            count: isLoading ? '...' : '$bloodCenters',
            label: 'Blood Centers',
          ),
          Container(
            width: 1,
            height: 32,
            color: BrandColors.borderSubtle,
          ),
          _buildStatColumn(
            count: isLoading ? '...' : '$campsOrganised',
            label: 'Camps Organised',
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({required String count, required String label}) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: BrandColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 11,
            color: BrandColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
