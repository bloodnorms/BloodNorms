// ============================================================================
// BloodNorms | blood_group_tile.dart
// Clean, minimal blood group selector tile component
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/blood_groups.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class BloodGroupTile extends StatefulWidget {
  final BloodGroup bloodGroup;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const BloodGroupTile({
    super.key,
    required this.bloodGroup,
    required this.isSelected,
    required this.onTap,
    this.size = 80.0,
  });

  @override
  State<BloodGroupTile> createState() => _BloodGroupTileState();
}

class _BloodGroupTileState extends State<BloodGroupTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final backgroundColor = isSelected ? BrandColors.primaryAction : Colors.white;
    final borderColor = isSelected ? BrandColors.primaryAction : BrandColors.borderSubtle;
    final textColor = isSelected ? Colors.white : BrandColors.textPrimary;
    final subtitleColor = isSelected ? Colors.white.withValues(alpha: 0.8) : BrandColors.textSecondary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _isPressed ? 0.96 : 1.0,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
            boxShadow: isSelected ? BrandColors.shadowFloating : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.bloodGroup.label,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: widget.size >= 80 ? 22 : 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (widget.size >= 80) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.bloodGroup.isPositive ? 'Rh +' : 'Rh −',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: BrandColors.primaryAction,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias for existing code.
typedef DuoBloodTile = BloodGroupTile;
