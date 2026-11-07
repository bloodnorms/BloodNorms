// ============================================================================
// BloodNorms | location_confirm_bottom_bar.dart
// Bottom sheet/bar showing selected place label and Continue CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.border, width: 2.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pin_drop_rounded,
                size: 20,
                color: BrandColors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  placeLabel,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: BrandColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: loc.t('cta.continue'),
              variant: ActionButtonVariant.primary,
              onPressed: () => context.push('/banks'),
            ),
          ),
        ],
      ),
    );
  }
}
