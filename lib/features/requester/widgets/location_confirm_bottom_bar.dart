// ============================================================================
// BloodNorms | location_confirm_bottom_bar.dart
// Bottom sheet/bar showing selected place label and Continue CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class LocationConfirmBottomBar extends StatelessWidget {
  final String placeLabel;

  const LocationConfirmBottomBar({
    super.key,
    required this.placeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: BrandColors.background,
        border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pin_drop_rounded,
                  size: 20,
                  color: BrandColors.statusError,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeLabel,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: BrandColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppPillButton(
              label: loc.t('cta.continue'),
              variant: AppPillButtonVariant.primary,
              isFullWidth: true,
              onPressed: () => context.push('/banks'),
            ),
          ],
        ),
      ),
    );
  }
}
