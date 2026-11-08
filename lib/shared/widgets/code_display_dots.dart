// ============================================================================
// BloodNorms | code_display_dots.dart
// Clean 6-digit Code Display Boxes Component
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

/// 6-digit Code Display Boxes
class DuoCodeDisplayDots extends StatelessWidget {
  final String code;
  final int length;

  const DuoCodeDisplayDots({
    super.key,
    required this.code,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final hasDigit = index < code.length;
        final digit = hasDigit ? code[index] : '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: hasDigit ? BrandColors.surfaceSoft : BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(
              color: hasDigit ? BrandColors.primaryAction : BrandColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: BrandColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

typedef CodeDisplayDots = DuoCodeDisplayDots;
