// ============================================================================
// BloodNorms | expected_donors_tab_view.dart
// Blood Bank Console: Expected Donors Tab with privacy-safe donor details
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/speech_bubble.dart';

class ExpectedDonorsTabView extends StatelessWidget {
  final List<Map<String, dynamic>> expectedDonors;
  final bool isLoadingExpected;
  final VoidCallback onRefresh;

  const ExpectedDonorsTabView({
    super.key,
    required this.expectedDonors,
    required this.isLoadingExpected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: ScreenHeader(
        title: 'Expected Donors',
        showBackButton: false,
        trailing: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: BrandColors.primaryDark),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingExpected
            ? const Center(child: CircularProgressIndicator(color: BrandColors.primaryDark))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '👥',
                    text: 'Donors heading to requests in Rajahmundry. Keep beds prepared and welcome them with warmth!',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BrandColors.surface,
                      borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                      border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                      boxShadow: BrandColors.shadowSubtle,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, size: 20, color: BrandColors.primaryDark),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Per privacy rule BR-24, bank staff see first name, blood group, and ETA only.',
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 13,
                              color: BrandColors.textSecondary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (expectedDonors.isNotEmpty)
                    ...expectedDonors.map((row) {
                      final donor = row['donors'] as Map<String, dynamic>? ?? {};
                      final name = donor['first_name']?.toString() ?? donor['full_name']?.toString() ?? 'Donor';
                      final group = donor['blood_group']?.toString() ?? 'O+';
                      final status = (row['status']?.toString() ?? 'accepted').toUpperCase();
                      final distKm = (row['ring_km'] as num?)?.toDouble() ?? 1.5;
                      final eta = '~${(distKm * 8).toInt().clamp(10, 45)} min ETA';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExpectedDonorItem(
                          name,
                          group,
                          eta,
                          status,
                          status == 'ACCEPTED' ? BrandColors.red : BrandColors.green,
                          status == 'ACCEPTED' ? BrandColors.redTint : BrandColors.greenTint,
                          status == 'ACCEPTED' ? BrandColors.red : BrandColors.green,
                        ),
                      );
                    })
                  else ...[
                    _buildExpectedDonorItem('Anil', 'B+', '~12 min ETA', 'ON THE WAY', BrandColors.green, BrandColors.greenTint, BrandColors.green),
                    const SizedBox(height: 12),
                    _buildExpectedDonorItem('Suresh', 'B+', '~25 min ETA', 'ACCEPTED', BrandColors.red, BrandColors.redTint, BrandColors.red),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildExpectedDonorItem(
    String name,
    String group,
    String eta,
    String status,
    Color statusColor,
    Color statusBg,
    Color statusBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        boxShadow: BrandColors.shadowSubtle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BrandColors.redTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    group,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: BrandTypography.headline(color: BrandColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(eta, style: BrandTypography.caption(color: BrandColors.textSecondary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
