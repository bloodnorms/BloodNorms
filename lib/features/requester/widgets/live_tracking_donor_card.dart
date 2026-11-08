// ============================================================================
// BloodNorms | live_tracking_donor_card.dart
// Live donor response card with milestone breadcrumb stepper (BR-12/13) & call CTA
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LiveTrackingDonorCard extends StatelessWidget {
  final DonorCardModel donor;
  final VoidCallback onCallDonor;

  const LiveTrackingDonorCard({
    super.key,
    required this.donor,
    required this.onCallDonor,
  });

  Widget _buildBreadcrumbStep({required String label, required bool isActive, required bool isDone}) {
    final color = isDone ? BrandColors.statusSuccess : (isActive ? BrandColors.primaryAction : BrandColors.borderSubtle);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? BrandColors.textPrimary : BrandColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbDivider({required bool isDone}) {
    return Container(
      width: 12,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? BrandColors.statusSuccess : BrandColors.borderSubtle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = donor.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAccepted ? BrandColors.statusSuccessTint : BrandColors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAccepted ? BrandColors.statusSuccess : BrandColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                donor.firstName.isNotEmpty ? donor.firstName[0].toUpperCase() : 'D',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isAccepted ? BrandColors.statusSuccess : BrandColors.textPrimary,
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
                    Flexible(
                      child: Text(
                        donor.firstName,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: BrandColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: BrandColors.statusErrorTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: Text(
                        donor.bloodGroup,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.statusError,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(donor.distanceBand, style: BrandTypography.caption(color: BrandColors.textSecondary)),
                    const Text(' · ', style: TextStyle(color: BrandColors.textMuted)),
                    const Icon(Icons.schedule_rounded, size: 13, color: BrandColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('~${donor.etaMinutes} min ETA', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildBreadcrumbStep(label: 'Alerted', isActive: true, isDone: true),
                    _buildBreadcrumbDivider(isDone: isAccepted),
                    _buildBreadcrumbStep(label: 'En Route', isActive: isAccepted, isDone: isAccepted),
                    _buildBreadcrumbDivider(isDone: donor.status == 'arrived' || donor.status == 'donated'),
                    _buildBreadcrumbStep(
                      label: 'Arrived',
                      isActive: donor.status == 'arrived' || donor.status == 'donated',
                      isDone: donor.status == 'donated',
                    ),
                  ],
                ),
                if (donor.donationCode != null && donor.donationCode!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pass: ${donor.donationCode}',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.statusSuccess,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCallDonor,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isAccepted ? BrandColors.statusSuccess : BrandColors.primaryAction,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.phone_rounded, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
