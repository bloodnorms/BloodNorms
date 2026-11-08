// ============================================================================
// BloodNorms | advisory_notice_card.dart
// Voluntary & Free Healthcare Advisory Notice + The BloodNorms Pledge Dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class AdvisoryNoticeCard extends StatelessWidget {
  const AdvisoryNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        onTap: () => _showTrustModal(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: BrandColors.statusErrorTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: BrandColors.statusError,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'BloodNorms is ',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 12,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: '100% voluntary & free',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '. Never pay any agent.',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 12,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: BrandColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrustModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BrandColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
          side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: BrandColors.statusErrorTint,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: BrandColors.statusError,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'The BloodNorms Pledge',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: BrandColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 100% Free & Voluntary: Blood donation in India is governed by the Drugs and Cosmetics Act. Selling or buying blood is illegal.\n\n'
              '• Verified Honest Stock: Blood banks report honest units directly.\n\n'
              '• Contact Shielding: Your number is shared only when a donor accepts your emergency request.',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 13,
                color: BrandColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          AppPillButton(
            label: 'I Understand',
            variant: AppPillButtonVariant.primary,
            height: 40,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}
