// ============================================================================
// BloodNorms | live_tracking_donors_section.dart
// Agreed donors section showing list, empty state, and verification code button
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'live_tracking_code_sheet.dart';
import 'live_tracking_donor_card.dart';
import 'live_tracking_empty_card.dart';

class LiveTrackingDonorsSection extends StatelessWidget {
  final bool isLoading;
  final String bloodGroup;
  final double currentRingKm;
  final String hospitalName;
  final List<DonorCardModel> donors;
  final ValueChanged<DonorCardModel> onCallDonor;
  final ValueChanged<String> onConfirmDonation;

  const LiveTrackingDonorsSection({
    super.key,
    required this.isLoading,
    required this.bloodGroup,
    required this.currentRingKm,
    required this.hospitalName,
    required this.donors,
    required this.onCallDonor,
    required this.onConfirmDonation,
  });

  @override
  Widget build(BuildContext context) {
    final agreedDonors = donors
        .where((d) =>
            d.status == 'accepted' ||
            d.status == 'on_the_way' ||
            d.status == 'arrived')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Agreed Donors', style: BrandTypography.title2(color: BrandColors.textPrimary)),
            TextButton.icon(
              onPressed: () => showLiveTrackingCodeSheet(
                context: context,
                onCodeSubmitted: onConfirmDonation,
              ),
              icon: const Icon(Icons.dialpad_rounded, size: 18, color: BrandColors.primaryDark),
              label: const Text(
                'ENTER CODE',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: BrandColors.primaryDark)),
          )
        else if (agreedDonors.isEmpty)
          LiveTrackingEmptyCard(
            bloodGroup: bloodGroup,
            currentRingKm: currentRingKm,
            hospitalName: hospitalName,
          )
        else
          ...agreedDonors.map((d) => LiveTrackingDonorCard(
                donor: d,
                onCallDonor: () => onCallDonor(d),
              )),
      ],
    );
  }
}

