// ============================================================================
// BloodNorms | duo_meter.dart
// Duolingo Feather Tactile Status Ring & Meter Component
// Candy 3D progress ring with glossy track and bold Arial centered stats
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

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

    return DuoMeter(
      value: units > 0 ? 1.0 : 0.0,
      color: ringColor,
      centerText: '$units',
      subText: 'units',
      size: size,
      strokeWidth: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    const trackColor = Color(0xFFE5E5E5);
    const textColor = BrandColors.textPrimary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DuoRingPainter(
              value: value,
              color: color,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerText != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerText!,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                if (subText != null)
                  Text(
                    subText!,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textSecondary,
                      height: 1.1,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DuoRingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _DuoRingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
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
  bool shouldRepaint(covariant _DuoRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

// Duolingo Candy Progress Bar (with 4px glossy reflection line)
class DuoProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color fillColor;
  final double height;

  const DuoProgressBar({
    super.key,
    required this.progress,
    this.fillColor = BrandColors.green,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clamped;
          if (barWidth <= 0) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 2, left: 6, right: 6),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

typedef StatusRing = DuoMeter;


/// Backward compatibility alias for existing code.
typedef DuoMeter = ProgressMeter;
