// ============================================================================
// BloodNorms | donor_profile_badges_section.dart
// Milestone badges list, unlocked recognition status, and certificate dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
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
            children: badges.map((badge) {
              final isUnlocked = badge.isUnlocked;
              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: BrandColors.border, width: 1.0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFFFFF9E6) : BrandColors.bgGrouped,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFFFFD700) : BrandColors.border,
                          width: 2.0,
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
                            children: [
                              Text(
                                badge.badgeName,
                                style: BrandTypography.headline(
                                  color: isUnlocked ? BrandColors.textPrimary : BrandColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: BrandColors.greenTint,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: BrandColors.greenShadow, width: 1.0),
                                  ),
                                  child: const Text(
                                    'UNLOCKED',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: BrandColors.bgGrouped,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: BrandColors.border, width: 1.0),
                                  ),
                                  child: Text(
                                    '$donationsCount / ${badge.requiredDonations}',
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
                            style: BrandTypography.caption(color: BrandColors.textSecondary),
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
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFD48806)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'View Certificate of Appreciation',
                                      style: TextStyle(
                                        fontFamily: BrandTypography.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD48806),
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
            }).toList(),
          ),
        ),
      ],
    );
  }
}

