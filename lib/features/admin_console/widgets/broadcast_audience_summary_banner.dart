// ============================================================================
// BloodNorms | broadcast_audience_summary_banner.dart
// Modern Minimal Summary Banner for Broadcast Audience & Cost
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPill('Matched', '$eligible donors', BrandColors.statusSuccessTint, BrandColors.statusSuccess),
          _buildPill('Suppressed', '$suppressed', BrandColors.surfaceMuted, BrandColors.textSecondary),
          _buildPill('Estimated cost', '₹${cost.toStringAsFixed(2)}', BrandColors.accentTint, BrandColors.accent),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 12,
              color: BrandColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
