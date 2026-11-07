// ============================================================================
// BloodNorms | blood_groups.dart
// Blood group definitions, family colors, compatibility rules per BR-04
// A = Blue, B = Green, AB = Purple, O = Red
// ============================================================================

import 'package:flutter/material.dart';

enum BloodGroupFamily {
  a,
  b,
  ab,
  o,
}

enum BloodGroup {
  aPositive('A+', BloodGroupFamily.a, true),
  aNegative('A-', BloodGroupFamily.a, false),
  bPositive('B+', BloodGroupFamily.b, true),
  bNegative('B-', BloodGroupFamily.b, false),
  abPositive('AB+', BloodGroupFamily.ab, true),
  abNegative('AB-', BloodGroupFamily.ab, false),
  oPositive('O+', BloodGroupFamily.o, true),
  oNegative('O-', BloodGroupFamily.o, false);

  final String label;
  final BloodGroupFamily family;
  final bool isPositive;

  const BloodGroup(this.label, this.family, this.isPositive);

  static BloodGroup? fromString(String? text) {
    if (text == null) return null;
    final clean = text.trim().toUpperCase().replaceAll(' ', '');
    for (final bg in BloodGroup.values) {
      if (bg.label == clean) return bg;
    }
    return null;
  }

  Color get familyColor {
    switch (family) {
      case BloodGroupFamily.a:
        return const Color(0xFF0A84FF); // Blue
      case BloodGroupFamily.b:
        return const Color(0xFF30B45A); // Green
      case BloodGroupFamily.ab:
        return const Color(0xFFAF52DE); // Purple
      case BloodGroupFamily.o:
        return const Color(0xFFFF3B30); // Red
    }
  }

  Color get tintFillColor {
    return familyColor.withValues(alpha: 0.15);
  }

  // Compatibility rule: Can this donor donate to the requester?
  bool canDonateTo(BloodGroup recipient) {
    if (this == recipient) return true;
    if (this == BloodGroup.oNegative) return true; // Universal red donor
    if (this == BloodGroup.oPositive && recipient.isPositive) return true;

    if (this == BloodGroup.aNegative &&
        (recipient == BloodGroup.aPositive ||
            recipient == BloodGroup.abNegative ||
            recipient == BloodGroup.abPositive)) {
      return true;
    }
    if (this == BloodGroup.aPositive && recipient == BloodGroup.abPositive) {
      return true;
    }

    if (this == BloodGroup.bNegative &&
        (recipient == BloodGroup.bPositive ||
            recipient == BloodGroup.abNegative ||
            recipient == BloodGroup.abPositive)) {
      return true;
    }
    if (this == BloodGroup.bPositive && recipient == BloodGroup.abPositive) {
      return true;
    }

    if (this == BloodGroup.abNegative && recipient == BloodGroup.abPositive) {
      return true;
    }

    return false;
  }
}

enum BloodComponentType {
  wholeBlood('whole_blood', 'Whole blood'),
  redCells('red_cells', 'Red cells'),
  platelets('platelets', 'Platelets'),
  plasma('plasma', 'Plasma');

  final String code;
  final String label;

  const BloodComponentType(this.code, this.label);
}

enum RequestUrgencyLevel {
  now('now', 'Now'),
  within6h('within_6h', '6 h'),
  within24h('within_24h', '24 h'),
  planned('planned', 'Planned');

  final String code;
  final String label;

  const RequestUrgencyLevel(this.code, this.label);
}

