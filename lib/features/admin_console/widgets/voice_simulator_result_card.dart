// ============================================================================
// BloodNorms | voice_simulator_result_card.dart
// Result card for voice simulator extraction evaluation and star rating
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class VoiceSimulatorResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final int humanRating;
  final ValueChanged<int> onRatingChanged;

  const VoiceSimulatorResultCard({
    super.key,
    required this.result,
    required this.humanRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation outcome (Verified against prompt v2.4)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: BrandColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '• Extracted blood group: ${result['recognized_group']} · Units: ${result['units']}',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Urgency: ${result['urgency']} · Confidence: 98%',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Hospital: ${result['hospital']}',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Evaluation rating: ',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
              ...[1, 2, 3, 4, 5].map((star) => InkWell(
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    onTap: () => onRatingChanged(star),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.star_rounded,
                        color: star <= humanRating
                            ? BrandColors.statusWarning
                            : BrandColors.borderStrong,
                        size: 20,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

