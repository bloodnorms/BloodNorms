// ============================================================================
// BloodNorms | requester_shield_view.dart
// Modern Minimal Requester Fraud Prevention & Abuse Shield Registry View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class RequesterShieldView extends StatelessWidget {
  final List<Map<String, dynamic>> requestersList;
  final void Function(String phone, bool currentBlocked) onToggleRequesterBlock;

  const RequesterShieldView({
    super.key,
    required this.requestersList,
    required this.onToggleRequesterBlock,
  });

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
            'Requester abuse & fraud shield',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Risk scoring and block controls for repetitive or suspicious requests',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...requestersList.map((r) {
            final phone = r['phone'] ?? '';
            final isBlocked = r['is_blocked'] == true;
            final total = r['total_requests'] ?? 1;
            final score = r['abuse_score'] ?? r['risk_score'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isBlocked ? BrandColors.statusErrorTint : BrandColors.accentTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBlocked ? Icons.block_rounded : Icons.phone_android_rounded,
                          size: 16,
                          color: isBlocked ? BrandColors.statusError : BrandColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: BrandColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$total requests · Risk score: $score/100',
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
                  AppPillButton(
                    label: isBlocked ? 'Unblock' : 'Block',
                    variant: isBlocked ? AppPillButtonVariant.secondary : AppPillButtonVariant.destructive,
                    onPressed: () => onToggleRequesterBlock(phone, isBlocked),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
