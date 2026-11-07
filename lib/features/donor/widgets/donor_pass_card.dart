// ============================================================================
// BloodNorms | donor_pass_card.dart
// 3D physical-style pass card displaying donation verification code and hospital info
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrandColors.redShadow, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.redShadow,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isCancelled ? const Color(0xFF6B7280) : BrandColors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isCancelled ? Icons.block_rounded : Icons.verified_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isCancelled ? 'PASS CANCELLED' : 'OFFICIAL DONOR PASS',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    bloodGroup.label,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: isCancelled ? const Color(0xFF6B7280) : BrandColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Box
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  isCancelled ? 'STATUS' : 'DONATION VERIFICATION CODE',
                  style: BrandTypography.caption(color: BrandColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isCancelled ? const Color(0xFFF3F4F6) : BrandColors.redTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isCancelled ? const Color(0xFFD1D5DB) : BrandColors.redShadow, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: isCancelled ? const Color(0xFFE5E7EB) : BrandColors.redShadow,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    isCancelled ? 'VOID' : donationCode,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: isCancelled ? 24 : 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isCancelled ? 4 : 8,
                      color: isCancelled ? const Color(0xFF6B7280) : BrandColors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCancelled ? 'Requester closed this emergency request' : 'Single use • Valid for 24 hours',
                  style: BrandTypography.caption(color: BrandColors.textSecondary),
                ),
              ],
            ),
          ),

          // Dashed Separator Line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    color: index % 2 == 0 ? Colors.transparent : BrandColors.border,
                    height: 2,
                  ),
                ),
              ),
            ),
          ),

          // Hospital & Location Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DESTINATION HOSPITAL', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                const SizedBox(height: 6),
                Text(hospitalName, style: BrandTypography.title2(color: BrandColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: BrandColors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(hospitalArea, style: BrandTypography.body(color: BrandColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('WARD & BED', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                const SizedBox(height: 4),
                Text(wardDetail, style: BrandTypography.title3(color: BrandColors.textPrimary)),
                const SizedBox(height: 16),
                Text('REQUESTER', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                const SizedBox(height: 4),
                Text('$requesterName • $requesterPhone', style: BrandTypography.body(color: BrandColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
