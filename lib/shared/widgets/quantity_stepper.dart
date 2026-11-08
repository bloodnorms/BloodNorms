// ============================================================================
// BloodNorms | quantity_stepper.dart
// Clean, minimal stepper component with accessible touch targets
// Physical +/- circular buttons and clear units counter
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 10,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min;
    final canIncrement = value < max;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperCircleButton(
          icon: Icons.remove_rounded,
          isEnabled: canDecrement,
          onTap: () {
            if (canDecrement) onChanged(value - 1);
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: BrandColors.surfaceSoft,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.water_drop_rounded,
                    color: BrandColors.statusError,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value == 1 ? 'UNIT NEEDED' : 'UNITS NEEDED',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _StepperCircleButton(
          icon: Icons.add_rounded,
          isEnabled: canIncrement,
          onTap: () {
            if (canIncrement) onChanged(value + 1);
          },
        ),
      ],
    );
  }
}

class _StepperCircleButton extends StatefulWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StepperCircleButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_StepperCircleButton> createState() => _StepperCircleButtonState();
}

class _StepperCircleButtonState extends State<_StepperCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled
          ? (_) {
              setState(() => _pressed = true);
              HapticFeedback.selectionClick();
            }
          : null,
      onTapUp: widget.isEnabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: !widget.isEnabled
            ? 0.35
            : _pressed
                ? 0.7
                : 1.0,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: widget.isEnabled ? BrandColors.primaryAction : BrandColors.surfaceDisabled,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isEnabled ? BrandColors.primaryAction : BrandColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.isEnabled ? Colors.white : BrandColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias for existing code.
typedef DuoStepper = QuantityStepper;
