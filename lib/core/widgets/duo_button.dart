// ============================================================================
// BloodNorms | duo_button.dart
// Duolingo Feather 3D Tactile Pushable Button Component
// Physical 4px mechanical bottom bevel, Material Icons, Arial bold text
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';

enum DuoButtonVariant {
  primary,     // Duolingo Cardinal Red (Emergency & Action)
  success,     // Universal Action Done / Accepted Green
  secondary,   // Crisp White 3D with border
  tinted,      // Red Tint with solid base
  destructive, // Caution Red
  plain,       // Text only
}

class DuoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DuoButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final Color? customTint;

  const DuoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DuoButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 54.0,
    this.customTint,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color faceColor;
    Color shadowColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case DuoButtonVariant.primary:
        faceColor = isEnabled ? DuoColors.red : const Color(0xFFE5E5E5);
        shadowColor = isEnabled ? DuoColors.redShadow : const Color(0xFFCECECE);
        textColor = isEnabled ? Colors.white : const Color(0xFFAFAFAF);
        break;

      case DuoButtonVariant.success:
        faceColor = isEnabled ? DuoColors.green : const Color(0xFFE5E5E5);
        shadowColor = isEnabled ? DuoColors.greenShadow : const Color(0xFFCECECE);
        textColor = isEnabled ? Colors.white : const Color(0xFFAFAFAF);
        break;

      case DuoButtonVariant.secondary:
        faceColor = Colors.white;
        shadowColor = const Color(0xFFE0E0E0);
        textColor = widget.customTint ?? DuoColors.textPrimary;
        border = Border.all(color: const Color(0xFFE0E0E0), width: 2.0);
        break;

      case DuoButtonVariant.tinted:
        faceColor = DuoColors.redTint;
        shadowColor = DuoColors.red.withValues(alpha: 0.35);
        textColor = DuoColors.red;
        border = Border.all(color: DuoColors.red.withValues(alpha: 0.35), width: 2.0);
        break;

      case DuoButtonVariant.destructive:
        faceColor = const Color(0xFFFFECEC);
        shadowColor = const Color(0xFFFFCDCD);
        textColor = DuoColors.red;
        border = Border.all(color: const Color(0xFFFFCDCD), width: 2.0);
        break;

      case DuoButtonVariant.plain:
        faceColor = Colors.transparent;
        shadowColor = Colors.transparent;
        textColor = DuoColors.red;
        break;
    }

    const bevel = DuoColors.bevelHeight;
    final topOffset = (isEnabled && _isPressed) ? bevel : 0.0;
    final currentShadow = (isEnabled && _isPressed) ? 0.0 : bevel;

    if (widget.variant == DuoButtonVariant.plain) {
      return TextButton(
        onPressed: isEnabled ? widget.onPressed : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(widget.label, style: DuoTypography.button(color: textColor)),
          ],
        ),
      );
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        height: widget.height,
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(DuoColors.radiusButton),
          border: border,
          boxShadow: currentShadow > 0
              ? [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, currentShadow),
                    blurRadius: 0, // Sharp 3D bevel
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
                      style: DuoTypography.button(color: textColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// 176px Circular 3D Hero Button for "NEED BLOOD"
class DuoHeroButton extends StatefulWidget {
  final VoidCallback onTap;

  const DuoHeroButton({super.key, required this.onTap});

  @override
  State<DuoHeroButton> createState() => _DuoHeroButtonState();
}

class _DuoHeroButtonState extends State<DuoHeroButton> with SingleTickerProviderStateMixin {
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
          // Pulse halo
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 196,
              height: 196,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DuoColors.red.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Physical 3D Button
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
              margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: DuoColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: DuoColors.redShadow, width: 3.0),
                boxShadow: currentShadow > 0
                    ? [
                        BoxShadow(
                          color: DuoColors.redShadow,
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
                    style: DuoTypography.headline(color: Colors.white).copyWith(
                      letterSpacing: 1.0,
                    ),
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

// Duolingo Speech Bubble for the Mascot / Guidance
class DuoSpeechBubble extends StatelessWidget {
  final String text;
  final String? emoji;

  const DuoSpeechBubble({
    super.key,
    required this.text,
    this.emoji = '🩸',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mascot Avatar Circle
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DuoColors.redTint,
            shape: BoxShape.circle,
            border: Border.all(color: DuoColors.red, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji ?? '🩸',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Speech Bubble Box with 3D Border
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DuoColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: DuoColors.border,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              text,
              style: DuoTypography.body(color: DuoColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
