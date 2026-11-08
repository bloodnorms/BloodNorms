// ============================================================================
// BloodNorms | live_tracking_donors_section.dart
// Agreed donors list matching reference with counter pill & waiting dots
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'live_tracking_donor_card.dart';

class LiveTrackingDonorsSection extends StatelessWidget {
  final bool isLoading;
  final String bloodGroup;
  final int needUnits;
  final double currentRingKm;
  final String hospitalName;
  final List<DonorCardModel> donors;
  final ValueChanged<DonorCardModel> onCallDonor;
  final ValueChanged<String> onConfirmDonation;

  const LiveTrackingDonorsSection({
    super.key,
    required this.isLoading,
    required this.bloodGroup,
    required this.needUnits,
    required this.currentRingKm,
    required this.hospitalName,
    required this.donors,
    required this.onCallDonor,
    required this.onConfirmDonation,
  });

  @override
  Widget build(BuildContext context) {
    final agreedDonors = donors
        .where((d) => d.status == 'accepted' || d.status == 'on_the_way' || d.status == 'arrived')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Donors who've accepted",
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
              child: Text(
                '${agreedDonors.length}/$needUnits',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$bloodGroup and compatible types',
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: BrandColors.primaryDark)),
          )
        else ...[
          if (agreedDonors.isNotEmpty)
            ...agreedDonors.map((d) => LiveTrackingDonorCard(donor: d, onCallDonor: () => onCallDonor(d))),
          const SizedBox(height: 14),
          if (agreedDonors.length >= 3 || agreedDonors.length >= needUnits) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  '${agreedDonors.length} Donors Confirmed · Search Complete',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE57373), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE57373), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE57373), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text(
                  'Waiting for more, please be patient',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
