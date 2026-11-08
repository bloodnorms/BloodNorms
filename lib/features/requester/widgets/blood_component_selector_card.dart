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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BrandColors.statusErrorTint,
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    ),
                    child: const Icon(
                      Icons.water_drop_outlined,
                      size: 20,
                      color: BrandColors.statusError,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    component.label,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.textPrimary,
                    ),
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
      ),
    );
  }
}
