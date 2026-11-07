// ============================================================================
// BloodNorms | shared/widgets/segmented_picker.dart
//
// Pill-shaped sliding segmented control.
// Soft muted background with white elevated pill indicator for the active item.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class SegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Backward compatibility alias
typedef DuoSegmentItem<T> = SegmentItem<T>;

class SegmentedPicker<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final Color activeColor;
  final Color activeShadowColor;

  const SegmentedPicker({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.activeColor = BrandColors.primaryAction,
    this.activeShadowColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrandColors.surfaceMuted,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? BrandColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x10202124),
                            blurRadius: 4,
                            offset: Offset(0, 1),
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
                        size: 16,
                        color: isSelected ? BrandColors.textPrimary : BrandColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected ? BrandColors.textPrimary : BrandColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
