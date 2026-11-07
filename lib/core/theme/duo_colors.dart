// ============================================================================
// BloodNorms | duo_colors.dart
// Duolingo Feather Design System Color Tokens — Red Brand Identity
// High-contrast, vibrant, punchy colors: Red everywhere, Green for completed
// ============================================================================

import 'package:flutter/material.dart';

class DuoColors {
  // Brand Cardinal Red (Primary identity across all buttons, highlights, badges)
  static const Color red = Color(0xFFE52E2E);
  static const Color redShadow = Color(0xFFB71C1C);
  static const Color redTint = Color(0xFFFFEEEE);
  static const Color redSurface = Color(0xFFFFF5F5);

  // Universal Completed / Done Action Green
  static const Color green = Color(0xFF58CC02);
  static const Color greenShadow = Color(0xFF46A302);
  static const Color greenTint = Color(0xFFEAF8D8);

  // WhatsApp
  static const Color whatsApp = Color(0xFF25D366);
  static const Color whatsAppShadow = Color(0xFF1EAD52);

  // Solid Clear Neutrals (White theme only)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgGrouped = Color(0xFFF7F7F7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFFCECECE);
  static const Color divider = Color(0xFFE5E5E5);

  // High-Contrast Clear Typography Colors (Never washed out)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF888888);

  // 3D Physical Geometry
  static const double bevelHeight = 4.0;
  static const double radiusButton = 16.0;
  static const double radiusCard = 20.0;
  static const double radiusPill = 999.0;
}
