// ============================================================================
// BloodNorms | shared/theme/app_theme.dart
//
// Application theme configuration.
// Light theme only, pill buttons, soft rounded cards, minimal borders,
// confident near-black primary actions, and blue-violet accents.
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
      primaryColor: BrandColors.primaryAction,
      scaffoldBackgroundColor: BrandColors.background,
      fontFamily: BrandTypography.fontFamily,
      fontFamilyFallback: BrandTypography.fontFallbacks,
      colorScheme: const ColorScheme.light(
        primary: BrandColors.primaryAction,
        onPrimary: Colors.white,
        secondary: BrandColors.accent,
        onSecondary: Colors.white,
        surface: BrandColors.background,
        onSurface: BrandColors.textPrimary,
        surfaceContainerHighest: BrandColors.surfaceSoft,
        outline: BrandColors.borderSubtle,
        error: BrandColors.statusError,
        onError: Colors.white,
      ),
      dividerColor: BrandColors.borderSubtle,
      cardTheme: CardThemeData(
        color: BrandColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrandColors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(BrandColors.radiusDialog)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusInput),
          borderSide: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusInput),
          borderSide: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusInput),
          borderSide: const BorderSide(color: BrandColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusInput),
          borderSide: const BorderSide(color: BrandColors.statusError, width: 1.0),
        ),
        hintStyle: BrandTypography.body(color: BrandColors.textMuted),
        labelStyle: BrandTypography.label(color: BrandColors.textSecondary),
      ),
    );
  }

  // Pure light theme only — dark mode variants strictly removed
  static ThemeData get darkTheme => lightTheme;
}
