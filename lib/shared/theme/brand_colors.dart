// ============================================================================
// BloodNorms | shared/theme/brand_colors.dart
//
// Core design tokens: Clean, calm, minimal light theme.
// Pill-shaped controls, soft neutral surfaces, confident near-black primary actions,
// and blue-violet accents with soft tints.
// ============================================================================

import 'package:flutter/material.dart';

/// Central design tokens and color definitions for BloodNorms.
class BrandColors {
  // --- Modern Minimal Light Palette ---
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8F9FA);
  static const Color surfaceMuted = Color(0xFFF1F3F4);
  static const Color borderSubtle = Color(0xFFE8EAED);
  static const Color borderStrong = Color(0xFFDADCE0);

  // --- Confident Primary & Accent Tokens ---
  static const Color primaryAction = Color(0xFF1F1F1F);
  static const Color accent = Color(0xFF5B5BF0);
  static const Color accentTint = Color(0xFFEEF0FF);

  // --- Semantic Status Tokens (Color + Tint) ---
  static const Color statusSuccess = Color(0xFF1E8E3E);
  static const Color statusSuccessTint = Color(0xFFE6F4EA);
  static const Color statusWarning = Color(0xFFB06000);
  static const Color statusWarningTint = Color(0xFFFEF7E0);
  static const Color statusError = Color(0xFFD93025);
  static const Color statusErrorTint = Color(0xFFFCE8E6);

  // --- Standardized Typography Colors (WCAG AA compliant) ---
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textMuted = Color(0xFF9AA0A6);
  static const Color textDisabled = Color(0xFF9AA0A6);
  static const Color surfaceDisabled = Color(0xFFF1F3F4);

  // --- Shape & Geometry Tokens ---
  static const double radiusPill = 999.0;
  static const double radiusCard = 16.0;
  static const double radiusInput = 12.0;
  static const double radiusSmall = radiusInput;
  static const double radiusDialog = 24.0;
  static const double minTouchTarget = 44.0;

  // --- Floating Elevations ---
  static const List<BoxShadow> shadowFloating = [
    BoxShadow(
      color: Color(0x14202124),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowCardHover = [
    BoxShadow(
      color: Color(0x0A202124),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> shadowSubtle = shadowCardHover;

  // --- Backward-Compatible Aliases ---
  static const Color surface = background;
  static const Color primaryDark = primaryAction;
  static const Color bg = background;
  static const Color bgGrouped = surfaceSoft;
  static const Color cardBg = background;
  static const Color border = borderSubtle;
  static const Color borderDark = borderStrong;
  static const Color divider = borderSubtle;
  static const Color red = Color(0xFFE52E2E);
  static const Color redShadow = Color(0xFFB71C1C);
  static const Color redTint = statusErrorTint;
  static const Color redSurface = Color(0xFFFFF5F5);
  static const Color green = Color(0xFF58CC02);
  static const Color greenShadow = Color(0xFF46A302);
  static const Color greenTint = statusSuccessTint;
  static const Color whatsApp = Color(0xFF25D366);
  static const Color whatsAppShadow = Color(0xFF1EAD52);
  static const double bevelHeight = 1.0;
  static const double radiusButton = radiusPill;
}

/// Backward compatibility alias for existing code.
typedef DuoColors = BrandColors;
