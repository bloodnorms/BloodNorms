// ============================================================================
// BloodNorms | progress_meter.dart
// 3D tactile status ring & meter component with bold centered metrics
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

export 'step_progress_bar.dart';

class ProgressMeter extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final String? centerText;
  final String? subText;
  final double size;
  final double strokeWidth;

  const ProgressMeter({
    super.key,
    required this.value,
    required this.color,
    this.centerText,
    this.subText,
    this.size = 80.0,
    this.strokeWidth = 9.0,
  });

  factory ProgressMeter.stockFreshness({
    required int units,
    required String freshness, // 'fresh', 'moderate', 'stale'
    double size = 70.0,
  }) {
    Color ringColor;
    switch (freshness) {
      case 'fresh':
        ringColor = BrandColors.green;
        break;
      case 'moderate':
        ringColor = BrandColors.red;
        break;
      default:
        ringColor = BrandColors.textMuted;
        break;
    }

    return ProgressMeter(
      value: units > 0 ? 1.0 : 0.0,
      color: ringColor,
      centerText: '$units',
      subText: 'units',
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              value: value,
              color: color,
              trackColor: const Color(0xFFE5E5E5),
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerText != null)
                Text(
                  centerText!,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.28,
                    height: 1.0,
                  ),
                ),
              if (subText != null)
                Text(
                  subText!,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.textSecondary,
                    fontSize: size * 0.14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (value > 0.0) {
      final activePaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value.clamp(0.0, 1.0),
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

/// Backward compatibility alias for existing code.
typedef DuoMeter = ProgressMeter;
typedef StatusRing = ProgressMeter;
