// ============================================================================
// BloodNorms | bank_stock_group_tile.dart
// Card tile for blood bank inventory adjustment with tactile increment/decrement
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/blood_group_tile.dart';

class BankStockGroupTile extends StatelessWidget {
  final BloodGroup group;
  final int currentUnits;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const BankStockGroupTile({
    super.key,
    required this.group,
    required this.currentUnits,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              BloodGroupTile(
                bloodGroup: group,
                isSelected: false,
                size: 48,
                onTap: () {},
              ),
              const SizedBox(width: 14),
              Text(
                group.label,
                style: BrandTypography.title3(color: BrandColors.textPrimary),
              ),
            ],
          ),
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove_rounded,
                isEnabled: currentUnits > 0,
                onPressed: currentUnits > 0 ? onDecrement : null,
              ),
              SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    '$currentUnits',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add_rounded,
                isEnabled: true,
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
        onTap: isEnabled ? onPressed : null,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled ? BrandColors.surfaceSoft : BrandColors.surfaceDisabled,
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled ? BrandColors.borderSubtle : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: isEnabled ? BrandColors.textPrimary : BrandColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}
