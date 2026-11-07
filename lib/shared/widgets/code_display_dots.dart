// ============================================================================
// BloodNorms | code_display_dots.dart
// Tactile 6-digit Code Display Boxes Component
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
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            color: hasDigit ? BrandColors.redTint : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDigit ? BrandColors.red : BrandColors.border,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasDigit ? BrandColors.redShadow : BrandColors.border,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: hasDigit ? BrandColors.red : BrandColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

typedef CodeDisplayDots = DuoCodeDisplayDots;
