// ============================================================================
// BloodNorms | donor_pass_card.dart
// Clean digital pass card displaying donation verification code and hospital info
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorPassCard extends StatelessWidget {
  final String donationCode;
  final String hospitalName;
  final String hospitalArea;
  final String wardDetail;
  final String requesterName;
  final String requesterPhone;
  final BloodGroup bloodGroup;
  final bool isCancelled;

  const DonorPassCard({
    super.key,
    required this.donationCode,
    required this.hospitalName,
    required this.hospitalArea,
    required this.wardDetail,
    required this.requesterName,
    required this.requesterPhone,
    required this.bloodGroup,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: isCancelled ? BrandColors.surfaceMuted : BrandColors.primaryAction,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCancelled ? Icons.block_rounded : Icons.verified_rounded,
                      color: isCancelled ? BrandColors.textDisabled : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCancelled ? 'PASS CANCELLED' : 'OFFICIAL DONOR PASS',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: isCancelled ? BrandColors.textDisabled : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCancelled ? BrandColors.surfaceSoft : BrandColors.statusErrorTint,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  ),
                  child: Text(
                    bloodGroup.label,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: isCancelled ? BrandColors.textDisabled : BrandColors.statusError,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Box
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  isCancelled ? 'STATUS' : 'DONATION VERIFICATION CODE',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: isCancelled ? BrandColors.surfaceMuted : BrandColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: Text(
                    isCancelled ? 'VOID' : donationCode,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: isCancelled ? 24 : 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: isCancelled ? 4 : 8,
                      color: isCancelled ? BrandColors.textDisabled : BrandColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCancelled ? 'Requester closed this emergency request' : 'Single use · Valid for 24 hours',
                  style: BrandTypography.caption(color: BrandColors.textSecondary),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1, color: BrandColors.borderSubtle),

          // Hospital & Location Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DESTINATION HOSPITAL',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(hospitalName, style: BrandTypography.title2(color: BrandColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: BrandColors.statusError),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(hospitalArea, style: BrandTypography.body(color: BrandColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'WARD & BED',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(wardDetail, style: BrandTypography.title3(color: BrandColors.textPrimary)),
                const SizedBox(height: 14),
                const Text(
                  'REQUESTER',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$requesterName · $requesterPhone', style: BrandTypography.body(color: BrandColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
