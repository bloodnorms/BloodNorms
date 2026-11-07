// ============================================================================
// BloodNorms | duo_header_bar.dart
// Duolingo Feather App Bar Component
// Crisp White background, solid 2px bottom border, bold Arial title, Material icons
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? trailing;
  final VoidCallback? onBackOverride;
  final bool centerTitle;
  final TextStyle? titleStyle;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.trailing,
    this.onBackOverride,
    this.centerTitle = false,
    this.titleStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton && canPop;

    final effectiveLeading = leading ??
        (shouldShowBack
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: onBackOverride ?? () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: BrandColors.bgGrouped,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BrandColors.border, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: BrandColors.border,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              )
            : null);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: BrandColors.border,
            width: 2.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ?effectiveLeading,
                Expanded(
                  child: Text(
                    title,
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                    style: titleStyle ?? BrandTypography.title2(color: BrandColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// Backward compatibility alias for existing code.
typedef DuoHeaderBar = ScreenHeader;
