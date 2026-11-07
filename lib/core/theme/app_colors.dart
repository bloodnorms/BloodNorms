// ============================================================================
// BloodNorms | app_colors.dart
// Forwarding aliases for DuoColors
// ============================================================================

import 'package:flutter/material.dart';
import 'duo_colors.dart';
export 'duo_colors.dart';

class AppColors {
  // Brand Red
  static const Color redLight = DuoColors.red;
  static const Color redDark = DuoColors.red;
  static const Color redDeepLight = DuoColors.redShadow;
  static const Color redDeepDark = DuoColors.redShadow;
  static const Color redTintLight = DuoColors.redTint;
  static const Color redTintDark = DuoColors.redTint;

  // Completed / Success Green
  static const Color greenLight = DuoColors.green;
  static const Color greenDark = DuoColors.green;

  // WhatsApp
  static const Color whatsAppGreen = DuoColors.whatsApp;

  // Neutrals (White theme)
  static const Color bgLight = DuoColors.bgGrouped;
  static const Color surfaceLight = DuoColors.cardBg;
  static const Color surface2Light = DuoColors.bgGrouped;
  static const Color labelLight = DuoColors.textPrimary;
  static const Color label2Light = DuoColors.textSecondary;
  static const Color greyLight = DuoColors.textSecondary;
  static const Color separatorLight = DuoColors.border;

  // Geometry
  static const double radiusCard = DuoColors.radiusCard;
  static const double radiusButton = DuoColors.radiusButton;
  static const double radiusChip = DuoColors.radiusPill;
}
