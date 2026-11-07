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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.border, width: 1.5),
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
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.bold,
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
          child: _buildMetricPill(Icons.people_rounded, 'CONTACTED', '$contactedCount', BrandColors.textPrimary, const Color(0xFFF0F0F0)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricPill(Icons.check_circle_rounded, 'AGREED', '$acceptedCount', BrandColors.green, BrandColors.greenTint),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricPill(Icons.water_drop_rounded, 'NEEDED', '$needUnits', BrandColors.red, BrandColors.redTint),
        ),
      ],
    );
  }
}

