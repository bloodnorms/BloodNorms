// ============================================================================
// BloodNorms | duo_bottom_nav_bar.dart
// Duolingo Feather Custom Bottom Navigation Bar
// Physical 3D active tab highlights, Material Icons, Arial bold labels
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class DuoNavItem {
  final IconData icon;
  final String label;

  const DuoNavItem({
    required this.icon,
    required this.label,
  });
}

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DuoNavItem> items;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: BrandColors.border,
            width: 2.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: BrandColors.redTint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: BrandColors.red, width: 2.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: BrandColors.redShadow,
                                  offset: Offset(0, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isSelected ? BrandColors.red : BrandColors.textSecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? BrandColors.red : BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}



/// Backward compatibility alias for existing code.
typedef DuoBottomNavBar = AppNavBar;
typedef NavItem = DuoNavItem;
