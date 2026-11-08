// ============================================================================
// BloodNorms | screen_header.dart
// Clean, minimal app header bar component
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
  Size get preferredSize => const Size.fromHeight(56);

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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BrandColors.surfaceSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
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
            color: BrandColors.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
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
