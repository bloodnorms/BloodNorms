// ============================================================================
// BloodNorms | shared/theme/brand_typography.dart
//
// Modern geometric sans typography scale adhering to Material & Stitch standards:
// Display 40, Headline 28, Title 20, Body Large 16, Body 14 (default), Label 12.
// ============================================================================

import 'package:flutter/material.dart';
import 'brand_colors.dart';

/// Central typography hierarchy for BloodNorms.
class BrandTypography {
  static const String fontFamily = 'Arial';
  static const List<String> fontFallbacks = [
    'Plus Jakarta Sans',
    'Helvetica',
    'Segoe UI',
    'Noto Sans',
    'Noto Sans Telugu',
    'Noto Sans Devanagari',
    'sans-serif',
  ];

  // --- Core Scale (Stitch & Material Inspired) ---
  static TextStyle display({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  static TextStyle headline({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.28,
        color: color,
      );

  static TextStyle title({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle bodyLarge({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle body({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: color,
      );

  static TextStyle fieldLabel({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle label({Color color = BrandColors.textSecondary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: color,
      );

  static TextStyle mono({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // --- Backward-Compatible Aliases ---
  static TextStyle titleHero({Color color = BrandColors.textPrimary}) => display(color: color);
  static TextStyle title1({Color color = BrandColors.textPrimary}) => headline(color: color);
  static TextStyle title2({Color color = BrandColors.textPrimary}) => title(color: color);
  static TextStyle title3({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );
  static TextStyle button({Color color = Colors.white}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      );
  static TextStyle subhead({Color color = BrandColors.textSecondary}) => body(color: color);
  static TextStyle caption({Color color = BrandColors.textSecondary}) => label(color: color);
  static TextStyle numberHero({Color color = BrandColors.textPrimary}) => display(color: color);
}

/// Backward compatibility alias for existing code.
typedef DuoTypography = BrandTypography;
