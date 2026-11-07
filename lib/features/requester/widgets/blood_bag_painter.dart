// ============================================================================
// BloodNorms | blood_bag_painter.dart
// Custom Painter for the medical blood bag graphic on the hero card
// ============================================================================

import 'package:flutter/material.dart';

class BloodBagPainter extends CustomPainter {
  const BloodBagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintBag = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final strokeBag = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bloodPaint = Paint()
      ..color = const Color(0xFF880808)
      ..style = PaintingStyle.fill;

    final labelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final labelBorder = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tubePaint = Paint()
      ..color = const Color(0xFF9E1212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Outer Bag Rounded Rect
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 16, size.width - 20, size.height - 32),
      const Radius.circular(16),
    );

    // Inner Blood Fluid
    final bloodRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(13, 30, size.width - 26, size.height - 48),
      const Radius.circular(13),
    );

    canvas.drawRRect(bagRect, paintBag);
    canvas.drawRRect(bloodRect, bloodPaint);
    canvas.drawRRect(bagRect, strokeBag);

    // Top Eyelet Hole
    final eyeletPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 22), 4, eyeletPaint);

    // Label Card in Center
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 42, size.width - 40, 40),
      const Radius.circular(6),
    );
    canvas.drawRRect(labelRect, labelPaint);
    canvas.drawRRect(labelRect, labelBorder);

    // Blood drop icon on label
    final dropPaint = Paint()
      ..color = const Color(0xFFE52E2E)
      ..style = PaintingStyle.fill;
    final dropPath = Path();
    final cx = size.width / 2;
    dropPath.moveTo(cx, 48);
    dropPath.cubicTo(cx - 5, 54, cx - 7, 58, cx, 64);
    dropPath.cubicTo(cx + 7, 58, cx + 5, 54, cx, 48);
    canvas.drawPath(dropPath, dropPaint);

    // Barcode lines on label
    final barPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(26, 74), Offset(size.width - 26, 74), barPaint);

    // Bottom Tube hanging down
    final tubePath = Path();
    tubePath.moveTo(size.width / 2 + 6, size.height - 16);
    tubePath.cubicTo(
      size.width / 2 + 10,
      size.height,
      size.width / 2 + 25,
      size.height - 6,
      size.width / 2 + 20,
      size.height + 15,
    );
    canvas.drawPath(tubePath, tubePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
