// ============================================================================
// BloodNorms | donor_history_card.dart
// Card component displaying past verified blood donations and badge status
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorHistoryCard extends StatelessWidget {
  final String hospital;
  final String date;
  final String group;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final Color statusBorder;

  const DonorHistoryCard({
    super.key,
    required this.hospital,
    required this.date,
    required this.group,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.statusBorder,
  });

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital, style: BrandTypography.title3(color: BrandColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$date • $group Whole Blood', style: BrandTypography.caption(color: BrandColors.textSecondary)),
              ],
            ),
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
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonorEmptyHistoryCard extends StatelessWidget {
  const DonorEmptyHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        boxShadow: BrandColors.shadowSubtle,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.history_rounded, size: 36, color: BrandColors.textSecondary),
            const SizedBox(height: 8),
            Text('No Past Donations Yet', style: BrandTypography.headline(color: BrandColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'When you complete a donation at a hospital or blood bank, your verified record will appear here.',
              style: BrandTypography.caption(color: BrandColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
