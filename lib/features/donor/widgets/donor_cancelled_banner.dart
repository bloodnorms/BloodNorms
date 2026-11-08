// ============================================================================
// BloodNorms | donor_cancelled_banner.dart
// Alert banner displayed when an emergency blood request was cancelled
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorCancelledBanner extends StatelessWidget {
  final String outcomeReason;

  const DonorCancelledBanner({
    super.key,
    required this.outcomeReason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: BrandColors.redTint,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.red.withOpacity(0.25), width: 1.0),
        boxShadow: BrandColors.shadowSubtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: BrandColors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REQUEST CANCELLED BY REQUESTER',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reason: ${outcomeReason.isNotEmpty ? outcomeReason : "Blood fulfilled or no longer required"}.\n\nPlease do not proceed to the hospital. Thank you for your readiness to help!',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: BrandColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
