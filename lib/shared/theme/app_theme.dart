// ============================================================================
// BloodNorms | shared/theme/app_theme.dart
//
// Application theme configuration.
// High contrast, Arial typography, 3D tactile paper cards, Cardinal Red primary.
// ============================================================================

import 'package:flutter/material.dart';
import 'brand_colors.dart';
import 'brand_typography.dart';

/// Central theme provider for BloodNorms MaterialApp.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BrandColors.red,
      scaffoldBackgroundColor: BrandColors.bgGrouped,
      fontFamily: BrandTypography.fontFamily,
      fontFamilyFallback: BrandTypography.fontFallbacks,
      colorScheme: const ColorScheme.light(
        primary: BrandColors.red,
        onPrimary: Colors.white,
        secondary: BrandColors.green,
        onSecondary: Colors.white,
        surface: BrandColors.cardBg,
        onSurface: BrandColors.textPrimary,
        surfaceContainerHighest: BrandColors.border,
      ),
      dividerColor: BrandColors.border,
      cardTheme: CardThemeData(
        color: BrandColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          side: const BorderSide(color: BrandColors.border, width: 2.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrandColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusButton),
          borderSide: const BorderSide(color: BrandColors.border, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusButton),
          borderSide: const BorderSide(color: BrandColors.border, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusButton),
          borderSide: const BorderSide(color: BrandColors.red, width: 2.0),
        ),
        hintStyle: BrandTypography.body(color: BrandColors.textMuted),
        labelStyle: BrandTypography.headline(color: BrandColors.textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

