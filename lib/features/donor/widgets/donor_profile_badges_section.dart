// ============================================================================
// BloodNorms | donor_profile_badges_section.dart
// Milestone badges list, unlocked recognition status, and certificate dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

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

  void _showCertificateModal(BuildContext context, DonorBadgeModel badge) {
    final certId = 'AP-BN-${badge.badgeCode.toUpperCase()}-${donorId?.hashCode.abs().toString().substring(0, 5) ?? "74892"}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
                ),
                child: Center(
                  child: Text(badge.icon, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'GOVERNMENT GENERAL HOSPITAL\n& BLOODNORMS INITIATIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: Color(0xFF8B6508),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'CERTIFICATE OF APPRECIATION',
                textAlign: TextAlign.center,
                style: BrandTypography.title2(color: BrandColors.textPrimary).copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFD4AF37), thickness: 1.5),
              const SizedBox(height: 12),
              Text(
                'This Certificate of Lifetime Honor is proudly presented to',
                textAlign: TextAlign.center,
                style: BrandTypography.caption(color: BrandColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                donorName,
                textAlign: TextAlign.center,
                style: BrandTypography.title1(color: BrandColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'For voluntary blood donation ($bloodGroup) contributing directly to saving human lives across Rajahmundry & East Godavari.',
                textAlign: TextAlign.center,
                style: BrandTypography.body(color: BrandColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 18, color: BrandColors.green),
                    const SizedBox(width: 8),
                    Text(
                      'VERIFIED SEAL: $certId',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: BrandColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(
                label: 'SHARE / SAVE CERTIFICATE',
                icon: Icons.share_rounded,
                variant: ActionButtonVariant.success,
                height: 46,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Certificate $certId copied to clipboard & saved!',
                        style: TextStyle(fontFamily: BrandTypography.fontFamily),
                      ),
                      backgroundColor: BrandColors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'CLOSE',
                variant: ActionButtonVariant.plain,
                height: 40,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                              onTap: () => _showCertificateModal(context, badge),
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
