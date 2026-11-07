// ============================================================================
// BloodNorms | duo_keypad.dart
// Duolingo Feather 3D Tactile Keypad & Code Display Component
// 3x4 grid of physical 3D round keys + 6-digit code boxes with Material icons
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';

class DuoKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;

  const DuoKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 14),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 14),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72, height: 72), // Empty balance box
            const SizedBox(width: 20),
            _DuoKeyButton(digit: '0', onTap: () => onDigitPressed('0')),
            const SizedBox(width: 20),
            _DuoDeleteButton(onTap: onDeletePressed),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((digit) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _DuoKeyButton(
            digit: digit,
            onTap: () => onDigitPressed(digit),
          ),
        );
      }).toList(),
    );
  }
}

class _DuoKeyButton extends StatefulWidget {
  final String digit;
  final VoidCallback onTap;

  const _DuoKeyButton({
    required this.digit,
    required this.onTap,
  });

  @override
  State<_DuoKeyButton> createState() => _DuoKeyButtonState();
}

class _DuoKeyButtonState extends State<_DuoKeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const bevel = DuoColors.bevelHeight;
    final topOffset = _pressed ? bevel : 0.0;
    final currentShadow = _pressed ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: DuoColors.border, width: 2.0),
          boxShadow: currentShadow > 0
              ? const [
                  BoxShadow(
                    color: DuoColors.border,
                    offset: Offset(0, bevel),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.digit,
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: DuoColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DuoDeleteButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DuoDeleteButton({required this.onTap});

  @override
  State<_DuoDeleteButton> createState() => _DuoDeleteButtonState();
}

class _DuoDeleteButtonState extends State<_DuoDeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const bevel = DuoColors.bevelHeight;
    final topOffset = _pressed ? bevel : 0.0;
    final currentShadow = _pressed ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          shape: BoxShape.circle,
          border: Border.all(color: DuoColors.border, width: 2.0),
          boxShadow: currentShadow > 0
              ? const [
                  BoxShadow(
                    color: DuoColors.border,
                    offset: Offset(0, bevel),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_rounded,
            size: 24,
            color: DuoColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// 6-digit Code Display Boxes (Feather Style)
class DuoCodeDisplayDots extends StatelessWidget {
  final String code;
  final int length;

  const DuoCodeDisplayDots({
    super.key,
    required this.code,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final hasDigit = index < code.length;
        final digit = hasDigit ? code[index] : '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            color: hasDigit ? DuoColors.redTint : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDigit ? DuoColors.red : DuoColors.border,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasDigit ? DuoColors.redShadow : DuoColors.border,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: hasDigit ? DuoColors.red : DuoColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

typedef PasscodeKeypad = DuoKeypad;
typedef CodeDisplayDots = DuoCodeDisplayDots;
