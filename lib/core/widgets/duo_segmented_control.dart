// ============================================================================
// BloodNorms | duo_segmented_control.dart
// Duolingo Feather 3D Segmented Control Component
// Tactile choice buttons with red active indicator and 3D mechanical press
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';

class DuoSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const DuoSegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

typedef SegmentItem<T> = DuoSegmentItem<T>;

class DuoSegmentControl<T> extends StatelessWidget {
  final List<DuoSegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final Color activeColor;
  final Color activeShadowColor;

  const DuoSegmentControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.activeColor = DuoColors.red,
    this.activeShadowColor = DuoColors.redShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuoColors.border, width: 2.0),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onValueChanged(item.value);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeShadowColor,
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 18,
                        color: isSelected ? Colors.white : DuoColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : DuoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
