// ============================================================================
// BloodNorms | camp_date_box.dart
// Clean date badge showing month and day for blood drive cards
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class CampDateBox extends StatelessWidget {
  final String month;
  final String day;
  final bool isJoined;

  const CampDateBox({
    super.key,
    required this.month,
    required this.day,
    required this.isJoined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isJoined ? BrandColors.statusSuccessTint : BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(
          color: isJoined ? BrandColors.statusSuccess.withValues(alpha: 0.3) : BrandColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            month,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              color: isJoined ? BrandColors.statusSuccess : BrandColors.statusError,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              color: isJoined ? BrandColors.statusSuccess : BrandColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
