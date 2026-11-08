// ============================================================================
// BloodNorms | home_top_bar.dart
// Top App Bar with Navigation Drawer trigger, App Title, & Language Selector
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenLanguageModal;

  const HomeTopBar({
    super.key,
    required this.onOpenMenu,
    required this.onOpenLanguageModal,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: const BoxDecoration(
          color: BrandColors.background,
          border: Border(
            bottom: BorderSide(color: BrandColors.borderSubtle, width: 1.0),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Left 3-lines menu icon button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    onTap: onOpenMenu,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrandColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Title: BloodNorms in clean typography
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: BrandColors.statusError,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Language Selection Pill
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    onTap: onOpenLanguageModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: BrandColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 15,
                            color: BrandColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            loc.locale.languageCode.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
