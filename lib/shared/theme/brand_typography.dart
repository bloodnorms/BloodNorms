// ============================================================================
// BloodNorms | shared/theme/brand_typography.dart
//
// Strict Arial Font Hierarchy — Only Normal (w400) and Bold (w700) Weights
// Conforms to 05-UI-UX-DESIGN-SYSTEM.md design tokens.
// ============================================================================

import 'package:flutter/material.dart';
import 'brand_colors.dart';

/// Central typography hierarchy for BloodNorms.
class BrandTypography {
  static const String fontFamily = 'Arial';
  static const List<String> fontFallbacks = ['Helvetica', 'sans-serif'];

  // Headings & Large Titles (Bold only)
  static TextStyle titleHero({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle title1({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle title2({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle title3({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headline({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle button({Color color = Colors.white}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: color,
      );

  // Body & Subtitles (Normal only)
  static TextStyle body({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle subhead({Color color = BrandColors.textSecondary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle caption({Color color = BrandColors.textSecondary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle numberHero({Color color = BrandColors.textPrimary}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: color,
      );
}

/// Backward compatibility alias for existing code.
typedef DuoTypography = BrandTypography;
