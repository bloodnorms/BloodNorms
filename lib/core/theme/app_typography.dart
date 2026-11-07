// ============================================================================
// BloodNorms | app_typography.dart
// Typography aliases pointing to DuoTypography
// ============================================================================

import 'package:flutter/material.dart';
import 'duo_typography.dart';
export 'duo_typography.dart';

class AppTypography {
  static const String fontFamily = DuoTypography.fontFamily;
  static const List<String> fontFallbacks = DuoTypography.fontFallbacks;

  static TextStyle largeTitle({Color color = Colors.black}) =>
      DuoTypography.titleHero(color: color);

  static TextStyle title1({Color color = Colors.black}) =>
      DuoTypography.title1(color: color);

  static TextStyle title2({Color color = Colors.black}) =>
      DuoTypography.title2(color: color);

  static TextStyle title3({Color color = Colors.black}) =>
      DuoTypography.title3(color: color);

  static TextStyle headline({Color color = Colors.black}) =>
      DuoTypography.headline(color: color);

  static TextStyle body({Color color = Colors.black}) =>
      DuoTypography.body(color: color);

  static TextStyle callout({Color color = Colors.black}) =>
      DuoTypography.body(color: color);

  static TextStyle subhead({Color color = Colors.black}) =>
      DuoTypography.subhead(color: color);

  static TextStyle footnote({Color color = Colors.black}) =>
      DuoTypography.caption(color: color);

  static TextStyle caption({Color color = Colors.black}) =>
      DuoTypography.caption(color: color);

  static TextStyle numberHero({Color color = Colors.black}) =>
      DuoTypography.numberHero(color: color);
}
