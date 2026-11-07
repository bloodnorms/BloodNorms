// ============================================================================
// BloodNorms | blood_component_selector_card.dart
// Interactive card triggering blood component bottom sheet picker
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BloodComponentSelectorCard extends StatelessWidget {
  final BloodComponentType component;
  final VoidCallback onTap;

  const BloodComponentSelectorCard({
    super.key,
    required this.component,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BrandColors.border, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: BrandColors.border,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🩸', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  component.label,
                  style: BrandTypography.headline(color: BrandColors.textPrimary),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: BrandColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
