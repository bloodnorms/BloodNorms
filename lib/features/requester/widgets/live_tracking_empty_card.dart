// ============================================================================
// BloodNorms | live_tracking_empty_card.dart
// Empty search state showing active radar broadcasting message to donors
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LiveTrackingEmptyCard extends StatelessWidget {
  final String bloodGroup;
  final double currentRingKm;
  final String hospitalName;

  const LiveTrackingEmptyCard({
    super.key,
    required this.bloodGroup,
    required this.currentRingKm,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border, width: 2.0),
      ),
      child: Column(
        children: [
          const Icon(Icons.emergency_share_rounded, color: BrandColors.red, size: 36),
          const SizedBox(height: 10),
          Text(
            'Broadcasting Alerts to Donors',
            style: BrandTypography.title3(color: BrandColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Emergency alerts sent to verified $bloodGroup donors within ${currentRingKm.toStringAsFixed(1)} km radius of $hospitalName. Cards appear here live.',
            style: BrandTypography.caption(color: BrandColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
