// ============================================================================
// BloodNorms | broadcast_audience_view.dart
// Modern Minimal Regional Broadcast Audience Geofence & Breakdown View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';

class BroadcastAudienceView extends StatelessWidget {
  final Map<String, dynamic> audiencePreview;

  const BroadcastAudienceView({
    super.key,
    required this.audiencePreview,
  });

  @override
  Widget build(BuildContext context) {
    final samples = (audiencePreview['sample_donors'] as List<dynamic>?) ?? [];
    final suppressedList =
        (audiencePreview['suppressed_sample'] as List<dynamic>?) ?? [];

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
            'In-radius eligible donors',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (samples.isEmpty)
            const AppEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No eligible donors in this radius',
              description: 'Try widening the geofence slider to reach more registered donors.',
            )
          else
            ...samples.map((s) => _buildDonorTile(s, isEligible: true)),
          const SizedBox(height: 16),
          const Divider(color: BrandColors.borderSubtle),
          const SizedBox(height: 12),
          const Text(
            'Suppressed donors (outside radius or away)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (suppressedList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Zero suppressions for this query.',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...suppressedList.map((s) => _buildDonorTile(s, isEligible: false)),
        ],
      ),
    );
  }

  Widget _buildDonorTile(dynamic s, {required bool isEligible}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isEligible ? BrandColors.accentTint : BrandColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Text(
                  s['blood_group'] ?? 'O+',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: isEligible ? BrandColors.accent : BrandColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['name'] ?? 'Donor',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${s['distance_km']} km away · ${s['area'] ?? ''}, ${s['city'] ?? ''}',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isEligible ? BrandColors.statusSuccessTint : BrandColors.statusErrorTint,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            ),
            child: Text(
              isEligible ? 'Eligible' : 'Suppressed',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: isEligible ? BrandColors.statusSuccess : BrandColors.statusError,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
