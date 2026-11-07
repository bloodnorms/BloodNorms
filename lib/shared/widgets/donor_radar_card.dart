// ============================================================================
// BloodNorms | duo_radar_card.dart
// Duolingo Feather Tactile Radar Card Component
// 3D paper card, concentric expanding search rings, 3 gamified stat badges
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class DonorRadarCard extends StatefulWidget {
  final double currentRingKm;
  final int contactedCount;
  final int acceptedCount;
  final int needUnits;

  const DonorRadarCard({
    super.key,
    required this.currentRingKm,
    required this.contactedCount,
    required this.acceptedCount,
    required this.needUnits,
  });

  @override
  State<DonorRadarCard> createState() => _DonorRadarCardState();
}

class _DonorRadarCardState extends State<DonorRadarCard> with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Radar Graphic Area with Pulse Animation
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(180, 180),
                      painter: _DuoRadarPainter(
                        animationValue: _radarController.value,
                        ringKm: widget.currentRingKm,
                      ),
                    );
                  },
                ),
                // Center Radar Ping Pulse
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: BrandColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: BrandColors.redShadow,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrandColors.redTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: BrandColors.red, width: 1.5),
                    ),
                    child: Text(
                      'SEARCHING ${widget.currentRingKm.toStringAsFixed(1)} KM',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3 Gamified Metrics Badges
          Row(
            children: [
              Expanded(
                child: _buildDuoStatBadge(
                  icon: Icons.people_rounded,
                  label: 'CONTACTED',
                  value: '${widget.contactedCount}',
                  color: BrandColors.textPrimary,
                  bg: BrandColors.bgGrouped,
                  border: BrandColors.border,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDuoStatBadge(
                  icon: Icons.check_circle_rounded,
                  label: 'AGREED',
                  value: '${widget.acceptedCount}',
                  color: BrandColors.green,
                  bg: BrandColors.greenTint,
                  border: BrandColors.greenShadow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDuoStatBadge(
                  icon: Icons.water_drop_rounded,
                  label: 'NEEDED',
                  value: '${widget.needUnits}',
                  color: BrandColors.red,
                  bg: BrandColors.redTint,
                  border: BrandColors.redShadow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuoStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: BrandColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DuoRadarPainter extends CustomPainter {
  final double animationValue;
  final double ringKm;

  _DuoRadarPainter({
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

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), crosshairPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), crosshairPaint);
  }

  @override
  bool shouldRepaint(covariant _DuoRadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

typedef RadarCard = DuoRadarCard;


/// Backward compatibility alias for existing code.
typedef DuoRadarCard = DonorRadarCard;
