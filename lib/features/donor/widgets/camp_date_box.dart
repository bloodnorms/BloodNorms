// ============================================================================
// BloodNorms | camp_date_box.dart
// 3D tactile date badge showing month and day for blood drive cards
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
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isJoined ? BrandColors.greenTint : BrandColors.redTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJoined ? BrandColors.greenShadow : BrandColors.redShadow,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isJoined ? BrandColors.greenShadow : BrandColors.redShadow,
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            month,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              color: isJoined ? BrandColors.green : BrandColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              color: isJoined ? BrandColors.green : BrandColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
