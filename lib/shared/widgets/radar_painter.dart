// ============================================================================
// BloodNorms | radar_painter.dart
// Custom painter for concentric radar rings and animated wave pulses
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class DuoRadarPainter extends CustomPainter {
  final double animationValue;
  final double ringKm;

  DuoRadarPainter({
    required this.animationValue,
    required this.ringKm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Static concentric background rings
    final baseRingPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3.0), baseRingPaint);
    }

    // Animated expanding wave ring
    final waveRadius = maxRadius * animationValue;
    final wavePaint = Paint()
      ..color = BrandColors.red.withValues(alpha: (1.0 - animationValue) * 0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, waveRadius, wavePaint);

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DuoRadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
