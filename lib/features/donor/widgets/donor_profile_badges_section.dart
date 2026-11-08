// ============================================================================
// BloodNorms | donor_profile_badges_section.dart
// Milestone badges list, unlocked recognition status, and certificate dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'donor_badge_tile.dart';

class DonorProfileBadgesSection extends StatelessWidget {
  final List<DonorBadgeModel> badges;
  final int donationsCount;
  final String donorName;
  final String bloodGroup;
  final String? donorId;

  const DonorProfileBadgesSection({
    super.key,
    required this.badges,
    required this.donationsCount,
    required this.donorName,
    required this.bloodGroup,
    required this.donorId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milestones & Honors', style: BrandTypography.title3(color: BrandColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: BrandColors.statusErrorTint,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.3), width: 1.0),
              ),
              child: Text(
                '$donationsCount DONATIONS',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.statusError,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Official recognition by Government Hospitals & BloodNorms',
          style: BrandTypography.caption(color: BrandColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            children: badges.map((badge) => DonorBadgeTile(
              badge: badge,
              donorName: donorName,
              bloodGroup: bloodGroup,
              donorId: donorId,
            )).toList(),
          ),
        ),
      ],
    );
  }
}
