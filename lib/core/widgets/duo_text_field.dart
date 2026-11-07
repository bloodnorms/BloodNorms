// ============================================================================
// BloodNorms | duo_text_field.dart
// Duolingo Feather 3D Tactile Input Component
// Crisp white, 2px border, red focus state, 3D bottom bevel, Material prefix
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';

class DuoTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const DuoTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<DuoTextField> createState() => _DuoTextFieldState();
}

class _DuoTextFieldState extends State<DuoTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: DuoTypography.headline(color: DuoColors.textPrimary),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? DuoColors.red : DuoColors.border,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused ? DuoColors.redShadow : DuoColors.border,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    size: 22,
                    color: _isFocused ? DuoColors.red : DuoColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.maxLines,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: DuoColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: DuoColors.textMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (widget.suffix != null) widget.suffix!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

