// ============================================================================
// BloodNorms | pin_keypad.dart
// Clean, accessible numerical keypad for PIN verification
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

export 'code_display_dots.dart';

class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;

  const PinKeypad({
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
        const SizedBox(height: 12),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 64, height: 64),
            const SizedBox(width: 20),
            _PinKeyButton(digit: '0', onTap: () => onDigitPressed('0')),
            const SizedBox(width: 20),
            _PinDeleteButton(onTap: onDeletePressed),
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
          child: _PinKeyButton(
            digit: digit,
            onTap: () => onDigitPressed(digit),
          ),
        );
      }).toList(),
    );
  }
}

class _PinKeyButton extends StatefulWidget {
  final String digit;
  final VoidCallback onTap;

  const _PinKeyButton({
    required this.digit,
    required this.onTap,
  });

  @override
  State<_PinKeyButton> createState() => _PinKeyButtonState();
}

class _PinKeyButtonState extends State<_PinKeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.6 : 1.0,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: BrandColors.surfaceSoft,
            shape: BoxShape.circle,
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Center(
            child: Text(
              widget.digit,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: BrandColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDeleteButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PinDeleteButton({required this.onTap});

  @override
  State<_PinDeleteButton> createState() => _PinDeleteButtonState();
}

class _PinDeleteButtonState extends State<_PinDeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.6 : 1.0,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: BrandColors.surfaceSoft,
            shape: BoxShape.circle,
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 22,
              color: BrandColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

typedef PasscodeKeypad = DuoKeypad;

/// Backward compatibility alias for existing code.
typedef DuoKeypad = PinKeypad;
