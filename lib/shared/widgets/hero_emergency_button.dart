// ============================================================================
// BloodNorms | hero_emergency_button.dart
// Clean, minimal hero button for emergency blood requests with subtle halo
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
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
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
                color: BrandColors.statusError.withValues(alpha: 0.08),
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
            child: AnimatedScale(
              duration: const Duration(milliseconds: 100),
              scale: _isPressed ? 0.96 : 1.0,
              child: Container(
                width: 168,
                height: 168,
                decoration: const BoxDecoration(
                  color: BrandColors.statusError,
                  shape: BoxShape.circle,
                  boxShadow: BrandColors.shadowFloating,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NEED BLOOD',
                      style: BrandTypography.headline(color: Colors.white)
                          .copyWith(letterSpacing: 0.5, fontSize: 16),
                    ),
                  ],
                ),
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
