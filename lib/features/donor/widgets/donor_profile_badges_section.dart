// ============================================================================
// BloodNorms | donor_profile_badges_section.dart
// Milestone badges list, unlocked recognition status, and certificate dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import 'donor_badge_tile.dart';
import 'donor_badge_certificate_dialog.dart';

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
                color: BrandColors.redTint,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: BrandColors.redShadow, width: 1.0),
              ),
              child: Text(
                '$donationsCount DONATIONS',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
