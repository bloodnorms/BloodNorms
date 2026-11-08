// ============================================================================
// BloodNorms | shared/widgets/app_page_header.dart
//
// Standard view header with title, one-line friendly description,
// and single primary action button placed at top-right.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'app_pill_button.dart';

/// Unified page header for all views.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final IconData? primaryActionIcon;
  final Widget? trailing;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.primaryActionIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: BrandTypography.headline(color: BrandColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: BrandTypography.body(color: BrandColors.textSecondary),
              ),
            ],
          );

          Widget? actionBlock;
          if (trailing != null) {
            actionBlock = trailing;
          } else if (primaryActionLabel != null && onPrimaryAction != null) {
            actionBlock = AppPillButton(
              label: primaryActionLabel,
              icon: primaryActionIcon,
              onPressed: onPrimaryAction,
            );
          }

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleBlock,
                if (actionBlock != null) ...[
                  const SizedBox(height: 16),
                  actionBlock,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: titleBlock),
              if (actionBlock != null) ...[
                const SizedBox(width: 16),
                actionBlock,
              ],
            ],
          );
        },
      ),
    );
  }
}

