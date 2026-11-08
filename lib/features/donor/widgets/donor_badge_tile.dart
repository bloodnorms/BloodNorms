// ============================================================================
// BloodNorms | donor_badge_tile.dart
// Milestone badge recognition tile displaying icon, title, criteria & certificate CTA
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/donor_badge_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'donor_badge_certificate_dialog.dart';

class DonorBadgeTile extends StatelessWidget {
  final DonorBadgeModel badge;
  final String donorName;
  final String bloodGroup;
  final String? donorId;

  const DonorBadgeTile({
    super.key,
    required this.badge,
    required this.donorName,
    required this.bloodGroup,
    required this.donorId,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFFFFF9E6) : BrandColors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? const Color(0xFFFFD700) : BrandColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      badge.badgeName,
                      style: BrandTypography.headline(
                        color: isUnlocked
                            ? BrandColors.textPrimary
                            : BrandColors.textSecondary,
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: BrandColors.greenTint,
                          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        ),
                        child: const Text(
                          'UNLOCKED ✓',
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            color: BrandColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: BrandColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                        ),
                        child: Text(
                          '${badge.requiredDonations} DONATIONS',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            color: BrandColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: BrandTypography.caption(
                    color: BrandColors.textSecondary,
                  ),
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => showDonorBadgeCertificateDialog(
                      context: context,
                      badge: badge,
                      donorName: donorName,
                      bloodGroup: bloodGroup,
                      donorId: donorId,
                    ),
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 16,
                            color: Color(0xFFD48806),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View Certificate of Appreciation',
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD48806),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
