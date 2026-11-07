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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BloodGroupTile(
                bloodGroup: group,
                isSelected: false,
                size: 52,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? BrandColors.redTint : const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? BrandColors.redShadow : BrandColors.border,
            width: 2.0,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: BrandColors.border,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? BrandColors.red : BrandColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
