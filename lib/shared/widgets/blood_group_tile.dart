// ============================================================================
// BloodNorms | duo_blood_tile.dart
// Duolingo Feather 3D Tactile Blood Group Tile Component
// 80x80 physical 3D pushable card with 4px mechanical bottom shadow
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
    const bevel = BrandColors.bevelHeight;
    final topOffset = _isPressed ? bevel : 0.0;
    final currentShadow = _isPressed ? 0.0 : bevel;

    final isSelected = widget.isSelected;
    final faceColor = isSelected ? BrandColors.red : Colors.white;
    final shadowColor = isSelected ? BrandColors.redShadow : BrandColors.border;
    final borderColor = isSelected ? BrandColors.redShadow : BrandColors.border;
    final textColor = isSelected ? Colors.white : BrandColors.textPrimary;

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topOffset, bottom: bevel - currentShadow),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2.0),
          boxShadow: currentShadow > 0
              ? [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, currentShadow),
                    blurRadius: 0,
                  ),
                ]
              : null,
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
                    fontSize: widget.size >= 80 ? 24 : 16,
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
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : BrandColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
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
                      size: 14,
                      color: BrandColors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


/// Backward compatibility alias for existing code.
typedef DuoBloodTile = BloodGroupTile;
