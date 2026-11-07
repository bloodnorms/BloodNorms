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
    final color = isDone ? BrandColors.green : (isActive ? BrandColors.red : BrandColors.border);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 9.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? BrandColors.textPrimary : BrandColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbDivider({required bool isDone}) {
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: isDone ? BrandColors.green : BrandColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = donor.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isAccepted ? BrandColors.greenTint : BrandColors.redTint,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAccepted ? BrandColors.green : BrandColors.red,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                donor.firstName.isNotEmpty ? donor.firstName[0].toUpperCase() : 'D',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isAccepted ? BrandColors.green : BrandColors.red,
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
                        style: BrandTypography.headline(color: BrandColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: BrandColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        donor.bloodGroup,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                    const Icon(Icons.schedule_rounded, size: 14, color: BrandColors.textSecondary),
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
                    'Verification Pass: ${donor.donationCode}',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onCallDonor,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isAccepted ? BrandColors.green : BrandColors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isAccepted ? BrandColors.greenShadow : BrandColors.redShadow,
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.phone_rounded, size: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

