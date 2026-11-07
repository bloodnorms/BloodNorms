// ============================================================================
// BloodNorms | app_theme.dart
// Duolingo Feather Red Design System Theme
// High contrast, Arial typography, 3D paper cards, red primary
// ============================================================================

import 'package:flutter/material.dart';
import 'duo_colors.dart';
import 'duo_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: DuoColors.red,
      scaffoldBackgroundColor: DuoColors.bgGrouped,
      fontFamily: DuoTypography.fontFamily,
      fontFamilyFallback: DuoTypography.fontFallbacks,
      colorScheme: const ColorScheme.light(
        primary: DuoColors.red,
        onPrimary: Colors.white,
        secondary: DuoColors.green,
        onSecondary: Colors.white,
        surface: DuoColors.cardBg,
        onSurface: DuoColors.textPrimary,
        surfaceContainerHighest: DuoColors.border,
      ),
      dividerColor: DuoColors.border,
      cardTheme: CardThemeData(
        color: DuoColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuoColors.radiusCard),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DuoColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuoColors.radiusButton),
          borderSide: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuoColors.radiusButton),
          borderSide: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DuoColors.radiusButton),
          borderSide: const BorderSide(color: DuoColors.red, width: 2.0),
        ),
        hintStyle: DuoTypography.body(color: DuoColors.textMuted),
        labelStyle: DuoTypography.headline(color: DuoColors.textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
