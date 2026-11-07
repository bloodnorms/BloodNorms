// ============================================================================
// BloodNorms | action_button.dart
// 3D tactile pushable button component with physical 4px mechanical bottom bevel
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

export 'hero_emergency_button.dart';
export 'speech_bubble.dart';

enum ActionButtonVariant {
  primary,     // Cardinal Red (Emergency & Action)
  success,     // Done / Accepted Green
  secondary,   // Crisp White 3D with border
  tinted,      // Red Tint with solid base
  destructive, // Caution Red
  plain,       // Text only
}

class ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ActionButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final Color? customTint;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 54.0,
    this.customTint,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color faceColor;
    Color shadowColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case ActionButtonVariant.primary:
        faceColor = isEnabled ? BrandColors.red : const Color(0xFFE5E5E5);
        shadowColor = isEnabled ? BrandColors.redShadow : const Color(0xFFCECECE);
        textColor = isEnabled ? Colors.white : const Color(0xFFAFAFAF);
        break;

      case ActionButtonVariant.success:
        faceColor = isEnabled ? BrandColors.green : const Color(0xFFE5E5E5);
        shadowColor = isEnabled ? BrandColors.greenShadow : const Color(0xFFCECECE);
        textColor = isEnabled ? Colors.white : const Color(0xFFAFAFAF);
        break;

      case ActionButtonVariant.secondary:
        faceColor = Colors.white;
        shadowColor = const Color(0xFFE0E0E0);
        textColor = widget.customTint ?? BrandColors.textPrimary;
        border = Border.all(color: const Color(0xFFE0E0E0), width: 2.0);
        break;

      case ActionButtonVariant.tinted:
        faceColor = BrandColors.redTint;
        shadowColor = BrandColors.red.withValues(alpha: 0.35);
        textColor = BrandColors.red;
        border = Border.all(color: BrandColors.red.withValues(alpha: 0.35), width: 2.0);
        break;

      case ActionButtonVariant.destructive:
        faceColor = const Color(0xFFFFECEC);
        shadowColor = const Color(0xFFFFCDCD);
        textColor = BrandColors.red;
        border = Border.all(color: const Color(0xFFFFCDCD), width: 2.0);
        break;

      case ActionButtonVariant.plain:
        faceColor = Colors.transparent;
        shadowColor = Colors.transparent;
        textColor = BrandColors.red;
        break;
    }

    const bevel = BrandColors.bevelHeight;
    final topOffset = (isEnabled && _isPressed) ? bevel : 0.0;
    final currentShadow = (isEnabled && _isPressed) ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: isEnabled
          ? (_) {
              setState(() => _isPressed = true);
              HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        height: widget.height,
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: currentShadow > 0
              ? [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, currentShadow),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: BrandTypography.button(color: textColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias for existing code.
typedef DuoButton = ActionButton;
typedef DuoButtonVariant = ActionButtonVariant;
