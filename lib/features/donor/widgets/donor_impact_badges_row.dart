// ============================================================================
// BloodNorms | donor_impact_badges_row.dart
// Donor milestone impact summary badge row
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorImpactBadgesRow extends StatelessWidget {
  final int donationsCount;

  const DonorImpactBadgesRow({
    super.key,
    required this.donationsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Impact',
          style: BrandTypography.title3(color: BrandColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildBadge(
              emoji: '🎖️',
              title: 'Proven Donor',
              subtitle: '$donationsCount Donations',
              color: BrandColors.red,
              bgColor: BrandColors.redTint,
              shadowColor: BrandColors.redShadow,
            ),
            const SizedBox(width: 12),
            _buildBadge(
              emoji: '⭐',
              title: 'Reliable',
              subtitle: '100% answer',
              color: BrandColors.textPrimary,
              bgColor: const Color(0xFFF7F7F7),
              shadowColor: BrandColors.border,
            ),
            const SizedBox(width: 12),
            _buildBadge(
              emoji: '🎁',
              title: 'Kit Eligible',
              subtitle: 'Claimed',
              color: BrandColors.green,
              bgColor: BrandColors.greenTint,
              shadowColor: BrandColors.greenShadow,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color shadowColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: shadowColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: BrandColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
