// ============================================================================
// BloodNorms | home_top_bar.dart
// Top App Bar with Navigation Drawer trigger, App Title, & Language Selector
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
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
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Left 3-lines menu icon button
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onOpenMenu,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_rounded,
                        size: 22,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),

                // Center Title: BloodNorms in bold
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
                            color: Color(0xFFE52E2E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Language Selection Pill
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onOpenLanguageModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 15,
                          color: Color(0xFFE52E2E),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          loc.locale.languageCode.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
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
