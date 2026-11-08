// ============================================================================
// BloodNorms | donor_radar_card.dart
// Clean, minimal radar card component with expanding pulse rings and metric badges
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
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
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
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: BrandColors.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: BrandColors.primaryDark.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrandColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                    ),
                    child: Text(
                      'SEARCHING ${widget.currentRingKm.toStringAsFixed(1)} KM',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3 Metrics Badges
          Row(
            children: [
              Expanded(
                child: DuoStatBadge(
                  icon: Icons.people_outline_rounded,
                  label: 'CONTACTED',
                  value: '${widget.contactedCount}',
                  color: BrandColors.textPrimary,
                  bg: BrandColors.surfaceSoft,
                  border: BrandColors.borderSubtle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DuoStatBadge(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'AGREED',
                  value: '${widget.acceptedCount}',
                  color: BrandColors.statusSuccess,
                  bg: BrandColors.statusSuccessTint,
                  border: BrandColors.borderSubtle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DuoStatBadge(
                  icon: Icons.water_drop_outlined,
                  label: 'NEEDED',
                  value: '${widget.needUnits}',
                  color: BrandColors.statusError,
                  bg: BrandColors.statusErrorTint,
                  border: BrandColors.borderSubtle,
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
