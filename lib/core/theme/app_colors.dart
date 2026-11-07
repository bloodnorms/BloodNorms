// Forwarding bridge for backward compatibility during refactoring
export '../../shared/theme/brand_colors.dart';

import '../../shared/theme/brand_colors.dart';

class AppColors {
  // Brand Red
  static const Color redLight = BrandColors.red;
  static const Color redDark = BrandColors.red;
  static const Color redDeepLight = BrandColors.redShadow;
  static const Color redDeepDark = BrandColors.redShadow;
  static const Color redTintLight = BrandColors.redTint;
  static const Color redTintDark = BrandColors.redTint;

  // Completed / Success Green
  static const Color greenLight = BrandColors.green;
  static const Color greenDark = BrandColors.green;

  // WhatsApp
  static const Color whatsAppGreen = BrandColors.whatsApp;

  // Neutrals (White theme)
  static const Color bgLight = BrandColors.bgGrouped;
  static const Color surfaceLight = BrandColors.cardBg;
  static const Color surface2Light = BrandColors.bgGrouped;
  static const Color labelLight = BrandColors.textPrimary;
  static const Color label2Light = BrandColors.textSecondary;
  static const Color greyLight = BrandColors.textSecondary;
  static const Color separatorLight = BrandColors.border;

  // Geometry
  static const double radiusCard = BrandColors.radiusCard;
  static const double radiusButton = BrandColors.radiusButton;
  static const double radiusChip = BrandColors.radiusPill;
}
