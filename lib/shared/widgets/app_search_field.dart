// ============================================================================
// BloodNorms | shared/widgets/app_search_field.dart
//
// Pill-shaped search input field with thin outline icon and clear button.
// Minimum 44px height for forgiving touch targets.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

/// Accessible pill-shaped search input.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final double height;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search...',
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: BrandColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: BrandTypography.body(color: BrandColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: BrandTypography.body(color: BrandColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller?.clear();
                onChanged?.call('');
                onClear?.call();
              },
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: BrandColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

