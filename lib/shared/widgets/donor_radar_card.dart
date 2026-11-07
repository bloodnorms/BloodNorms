// ============================================================================
// BloodNorms | duo_radar_card.dart
// Duolingo Feather Tactile Radar Card Component
// 3D paper card, concentric expanding search rings, 3 gamified stat badges
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'donor_stat_badge.dart';
import 'radar_painter.dart';

export 'donor_stat_badge.dart';
export 'radar_painter.dart';

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
                      painter: DuoRadarPainter(
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
                child: DuoStatBadge(
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
                child: DuoStatBadge(
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
                child: DuoStatBadge(
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
}

typedef RadarCard = DuoRadarCard;

/// Backward compatibility alias for existing code.
typedef DuoRadarCard = DonorRadarCard;
