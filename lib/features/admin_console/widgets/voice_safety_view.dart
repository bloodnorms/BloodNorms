// ============================================================================
// BloodNorms | voice_safety_view.dart
// Modern Minimal Daily AI Voice Safety Quota & Minutes Gauge View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/progress_meter.dart';

class VoiceSafetyView extends StatelessWidget {
  const VoiceSafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily voice minutes safety gauge',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Usage tracking and automatic circuit breaker for telephony voice calls',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ProgressMeter(
                value: 0.15,
                color: BrandColors.accent,
                centerText: '9m',
                subText: 'used',
                size: 84,
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '9 of 60 daily safety minutes used',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'System automatically fails over to keypad telephony IVR if the daily threshold is exceeded.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
