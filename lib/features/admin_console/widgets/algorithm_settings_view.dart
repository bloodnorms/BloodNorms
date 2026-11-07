// ============================================================================
// BloodNorms | algorithm_settings_view.dart
// Modern Minimal Search Algorithm & Ring Expansion Rules Desk
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AlgorithmSettingsView extends StatelessWidget {
  const AlgorithmSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search algorithm parameters',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Emergency concentric ring expansion rules and telephony gates',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildParamTile('Wave 1 Initial Radius', '1.5 km (3 nearby verified donors)'),
          _buildParamTile('Wave 2 Expansion', '+2.0 km (Total 3.5 km ring)'),
          _buildParamTile('Wave 3 Expansion', '+2.0 km (Total 5.5 km ring)'),
          _buildParamTile('Max Geofence Cap', '15.0 km maximum search radius'),
          _buildParamTile('Telephony Outbound Gates', 'Gates enforced at 70 km, 90 km, 100 km'),
          _buildParamTile('Donor Cooldown Period', '90 days between blood donations'),
        ],
      ),
    );
  }

  Widget _buildParamTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 12,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
