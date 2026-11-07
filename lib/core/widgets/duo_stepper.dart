// ============================================================================
// BloodNorms | duo_stepper.dart
// Duolingo Feather 3D Tactile Stepper Component
// Physical pushable round +/- buttons with heart units indicator
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';

class DuoStepper extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const DuoStepper({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 10,
    required this.onChanged,
  });

  @override
  State<DuoStepper> createState() => _DuoStepperState();
}

class _DuoStepperState extends State<DuoStepper> {
  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.value > widget.min;
    final canIncrement = widget.value < widget.max;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minus Button
        _DuoStepperCircleButton(
          icon: Icons.remove_rounded,
          isEnabled: canDecrement,
          onTap: () {
            if (canDecrement) {
              widget.onChanged(widget.value - 1);
            }
          },
        ),

        // Value Box with Hearts
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.value}',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: DuoColors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.favorite_rounded,
                    color: DuoColors.red,
                    size: 28,
                  ),
                ],
              ),
              Text(
                widget.value == 1 ? 'UNIT NEEDED' : 'UNITS NEEDED',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: DuoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Plus Button
        _DuoStepperCircleButton(
          icon: Icons.add_rounded,
          isEnabled: canIncrement,
          onTap: () {
            if (canIncrement) {
              widget.onChanged(widget.value + 1);
            }
          },
        ),
      ],
    );
  }
}

class _DuoStepperCircleButton extends StatefulWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _DuoStepperCircleButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_DuoStepperCircleButton> createState() => _DuoStepperCircleButtonState();
}

class _DuoStepperCircleButtonState extends State<_DuoStepperCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const bevel = DuoColors.bevelHeight;
    final topOffset = (widget.isEnabled && _pressed) ? bevel : 0.0;
    final currentShadow = (widget.isEnabled && _pressed) ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: widget.isEnabled
          ? (_) {
              setState(() => _pressed = true);
              HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: widget.isEnabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: widget.isEnabled ? DuoColors.red : const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isEnabled ? DuoColors.redShadow : DuoColors.border,
            width: 2.0,
          ),
          boxShadow: currentShadow > 0
              ? [
                  BoxShadow(
                    color: widget.isEnabled ? DuoColors.redShadow : DuoColors.border,
                    offset: Offset(0, currentShadow),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 28,
            color: widget.isEnabled ? Colors.white : DuoColors.textMuted,
          ),
        ),
      ),
    );
  }
}
