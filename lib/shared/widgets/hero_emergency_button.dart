// ============================================================================
// BloodNorms | hero_emergency_button.dart
// 176px Circular 3D Hero Button for emergency blood requests with pulse halo
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class HeroEmergencyButton extends StatefulWidget {
  final VoidCallback onTap;

  const HeroEmergencyButton({super.key, required this.onTap});

  @override
  State<HeroEmergencyButton> createState() => _HeroEmergencyButtonState();
}

class _HeroEmergencyButtonState extends State<HeroEmergencyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bevel = 6.0;
    final topOffset = _isPressed ? bevel : 0.0;
    final currentShadow = _isPressed ? 0.0 : bevel;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 196,
              height: 196,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.red.withValues(alpha: 0.12),
              ),
            ),
          ),
          GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              HapticFeedback.mediumImpact();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              margin: EdgeInsets.only(
                top: topOffset,
                bottom: bevel - currentShadow,
              ),
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: BrandColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: BrandColors.redShadow, width: 3.0),
                boxShadow: currentShadow > 0
                    ? [
                        BoxShadow(
                          color: BrandColors.redShadow,
                          offset: Offset(0, currentShadow),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NEED BLOOD',
                    style: BrandTypography.headline(color: Colors.white)
                        .copyWith(letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias
typedef DuoHeroButton = HeroEmergencyButton;
