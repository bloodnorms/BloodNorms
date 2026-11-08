// ============================================================================
// BloodNorms | shared/widgets/app_empty_state.dart
//
// Friendly, calm empty state with soft-tinted circle icon,
// one plain explanation sentence, and a prominent action button.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'app_pill_button.dart';

/// Standard empty state container.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: BrandColors.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: BrandColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: BrandTypography.title(color: BrandColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                description,
                style: BrandTypography.body(color: BrandColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppPillButton(
                label: actionLabel,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

