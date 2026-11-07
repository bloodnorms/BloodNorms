// ============================================================================
// BloodNorms | shared/widgets/app_pill_button.dart
//
// Tactile, pill-shaped action button with micro-animation press feedback.
// Primary near-black pill, secondary outlined pill, tonal accent pill.
// Adheres to the 44px minimum tap target constraint.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

enum AppPillButtonVariant {
  primary,
  secondary,
  tonal,
  destructive,
  text,
}

/// Tactile, accessible pill-shaped button.
class AppPillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppPillButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppPillButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 44.0,
  });

  @override
  State<AppPillButton> createState() => _AppPillButtonState();
}

class _AppPillButtonState extends State<AppPillButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    if (widget.onPressed == null) return BrandColors.surfaceMuted;
    switch (widget.variant) {
      case AppPillButtonVariant.primary:
        return BrandColors.primaryAction;
      case AppPillButtonVariant.secondary:
        return Colors.transparent;
      case AppPillButtonVariant.tonal:
        return BrandColors.accentTint;
      case AppPillButtonVariant.destructive:
        return BrandColors.statusErrorTint;
      case AppPillButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) return BrandColors.textDisabled;
    switch (widget.variant) {
      case AppPillButtonVariant.primary:
        return Colors.white;
      case AppPillButtonVariant.secondary:
        return BrandColors.textPrimary;
      case AppPillButtonVariant.tonal:
        return BrandColors.accent;
      case AppPillButtonVariant.destructive:
        return BrandColors.statusError;
      case AppPillButtonVariant.text:
        return BrandColors.textPrimary;
    }
  }

  BorderSide _getBorderSide() {
    if (widget.variant == AppPillButtonVariant.secondary && widget.onPressed != null) {
      return const BorderSide(color: BrandColors.borderStrong, width: 1.0);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final borderSide = _getBorderSide();

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          side: borderSide,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          onTap: widget.isLoading ? null : widget.onPressed,
          onHighlightChanged: (pressed) {
            setState(() => _isPressed = pressed);
          },
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

