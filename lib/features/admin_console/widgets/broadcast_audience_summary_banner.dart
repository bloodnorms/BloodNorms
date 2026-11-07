// ============================================================================
// BloodNorms | broadcast_audience_summary_banner.dart
// Summary Banner for Broadcast Audience Matched Count, Suppressions & Cost
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BroadcastAudienceSummaryBanner extends StatelessWidget {
  final int eligible;
  final int suppressed;
  final double cost;

  const BroadcastAudienceSummaryBanner({
    super.key,
    required this.eligible,
    required this.suppressed,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '🎯 Matched Audience: $eligible donors',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '🚫 Suppressed: $suppressed donors',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              color: BrandColors.textSecondary,
            ),
          ),
          Text(
            'Cost: ₹${cost.toStringAsFixed(2)} INR',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              color: BrandColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
