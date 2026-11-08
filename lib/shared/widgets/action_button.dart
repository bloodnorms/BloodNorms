// ============================================================================
// BloodNorms | action_button.dart
// Modern, clean, minimal pill action button component
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

export 'hero_emergency_button.dart';
export 'speech_bubble.dart';

enum ActionButtonVariant {
  primary,     // Confident primary action
  success,     // Done / Accepted
  secondary,   // Clean outlined / tonal secondary
  tinted,      // Subtle soft tint
  destructive, // Caution / Reject
  plain,       // Minimal text only
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
    this.height = 48.0,
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

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case ActionButtonVariant.primary:
        backgroundColor = isEnabled ? BrandColors.primaryAction : BrandColors.surfaceDisabled;
        textColor = isEnabled ? Colors.white : BrandColors.textDisabled;
        border = null;
        break;

      case ActionButtonVariant.success:
        backgroundColor = isEnabled ? BrandColors.statusSuccess : BrandColors.surfaceDisabled;
        textColor = isEnabled ? Colors.white : BrandColors.textDisabled;
        border = null;
        break;

      case ActionButtonVariant.secondary:
        backgroundColor = Colors.white;
        textColor = widget.customTint ?? BrandColors.textPrimary;
        border = Border.all(color: BrandColors.borderSubtle, width: 1.0);
        break;

      case ActionButtonVariant.tinted:
        backgroundColor = BrandColors.surfaceSoft;
        textColor = widget.customTint ?? BrandColors.textPrimary;
        border = Border.all(color: BrandColors.borderSubtle, width: 1.0);
        break;

      case ActionButtonVariant.destructive:
        backgroundColor = BrandColors.statusErrorTint;
        textColor = BrandColors.statusError;
        border = Border.all(color: BrandColors.statusError.withValues(alpha: 0.2), width: 1.0);
        break;

      case ActionButtonVariant.plain:
        backgroundColor = Colors.transparent;
        textColor = widget.customTint ?? BrandColors.textPrimary;
        border = null;
        break;
    }

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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.85 : 1.0,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            border: border,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: textColor),
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
      ),
    );
  }
}

/// Backward compatibility alias for existing code.
typedef DuoButton = ActionButton;
typedef DuoButtonVariant = ActionButtonVariant;
