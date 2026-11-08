// ============================================================================
// BloodNorms | live_tracking_metrics_row.dart
// Metrics badge row for live request tracking (Contacted, Agreed, Needed)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LiveTrackingMetricsRow extends StatelessWidget {
  final int contactedCount;
  final int acceptedCount;
  final int needUnits;

  const LiveTrackingMetricsRow({
    super.key,
    required this.contactedCount,
    required this.acceptedCount,
    required this.needUnits,
  });

  Widget _buildMetricPill(IconData icon, String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricPill(Icons.people_outline_rounded, 'CONTACTED', '$contactedCount', BrandColors.textPrimary, BrandColors.surfaceSoft),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricPill(Icons.check_circle_outline_rounded, 'AGREED', '$acceptedCount', BrandColors.statusSuccess, BrandColors.statusSuccessTint),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricPill(Icons.water_drop_outlined, 'NEEDED', '$needUnits', BrandColors.statusError, BrandColors.statusErrorTint),
        ),
      ],
    );
  }
}
